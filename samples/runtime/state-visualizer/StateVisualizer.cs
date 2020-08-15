// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.Collections.Generic;
using System.Numerics;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Quantum.IQSharp.ExecutionPathTracer;

namespace Microsoft.Quantum.Samples.StateVisualizer
{
    internal class StateVisualizer
    {
        private readonly QuantumSimulator simulator;
        private readonly StateDumper stateDumper;
        private readonly IWebHost host;
        private readonly IHubContext<StateVisualizerHub> context;
        private readonly ManualResetEvent advanceEvent = new ManualResetEvent(true);
        private readonly CancellationTokenSource cancellationTokenSource = new CancellationTokenSource();
        private readonly IList<(string method, object[] args)> history = new List<(string, object[])>();
        private readonly ExecutionPathTracer tracer;

        public StateVisualizer(QuantumSimulator simulator)
        {
            if (simulator == null)
            {
                throw new ArgumentNullException(nameof(simulator));
            }

            simulator.OnOperationEnd += OnOperationEndHandler;
            this.tracer = new ExecutionPathTracer();
            this.simulator = simulator.WithExecutionPathTracer(this.tracer);
            stateDumper = new StateDumper(simulator);

            host = WebHost
                .CreateDefaultBuilder()
                .UseStartup<Startup>()
                .ConfigureServices(services =>
                {
                    // Register ourselves as a service so that the different
                    // hubs and controllers can use us through DI.
                    services.AddSingleton(typeof(StateVisualizer), this);
                })
                .UseUrls("http://localhost:5000")
                .UseKestrel()
                .Build();
            new Thread(host.Run).Start();
            context = GetService<IHubContext<StateVisualizerHub>>();
        }

        public async Task Run(Func<IOperationFactory, Task<QVoid>> operation) =>
            await operation(simulator);

        public async Task<O> Run<I, O>(Func<IOperationFactory, I, Task<O>> operation, I args) =>
            await operation(simulator, args);

        public void GetExecutionPath()
        {
            var executionPath = this.tracer.GetExecutionPath().ToJson();
            BroadcastAsync("ExecutionPath", executionPath).Wait();
        }

        private T GetService<T>() =>
            (T)host.Services.GetService(typeof(T));

        private async Task BroadcastAsync(string method, params object[] args)
        {
            history.Add((method, args));
            await context.Clients.All.SendCoreAsync(method, args);
        }

        private void OnOperationEndHandler(ICallable operation, IApplyData result)
        {
            var currentOperation = this.tracer.operations.Peek();
            if (currentOperation == null) return;
            if (currentOperation.CustomMetadata == null) currentOperation.CustomMetadata = new Dictionary<string, object>();
            if (currentOperation.CustomMetadata.ContainsKey("state")) return;
            // Add current register state as metadata to operation
            currentOperation.CustomMetadata["state"] = stateDumper.DumpAndGetAmplitudes();
        }
    }

    internal class StateDumper : QuantumSimulator.StateDumper
    {
        private List<Complex> amplitudes = new List<Complex>();

        public StateDumper(QuantumSimulator simulator) : base(simulator)
        {
        }

        public override bool Callback(uint index, double real, double imaginary)
        {
            amplitudes.Add(new Complex(real, imaginary));
            return true;
        }

        public override bool Dump(IQArray<Qubit> qubits = null)
        {
            amplitudes = new List<Complex>();
            return base.Dump(qubits);
        }

        public Complex[] GetAmplitudes() => amplitudes.ToArray();

        public Complex[] DumpAndGetAmplitudes(IQArray<Qubit> qubits = null)
        {
            Dump(qubits);
            return GetAmplitudes();
        }
    }
}
