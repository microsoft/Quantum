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
using System.Linq;
using System.Numerics;
using System.Threading;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Samples.VisualDebugger
{
    internal class VisualDebugger
    {
        private readonly QuantumSimulator simulator;
        private readonly StateDumper stateDumper;
        private readonly IWebHost host;
        private readonly IHubContext<VisualHub> context;
        private readonly ManualResetEvent advanceEvent = new ManualResetEvent(true);
        private readonly IList<(string method, object[] args)> history = new List<(string, object[])>();

        public VisualDebugger(QuantumSimulator simulator)
        {
            if (simulator == null)
            {
                throw new ArgumentNullException(nameof(simulator));
            }

            simulator.OnOperationStart += OnOperationStartHandler;
            simulator.OnOperationEnd += OnOperationEndHandler;
            this.simulator = simulator;
            stateDumper = new StateDumper(simulator);

            host = WebHost
                .CreateDefaultBuilder()
                .UseStartup<Startup>()
                .ConfigureServices(services =>
                {
                    // Register ourselves as a service so that the different
                    // hubs and controllers can use us through DI.
                    services.AddSingleton(typeof(VisualDebugger), this);
                })
                .UseUrls("http://localhost:5000")
                .UseKestrel()
                .Build();
            new Thread(host.Run).Start();
            context = GetService<IHubContext<VisualHub>>();
        }

        public async Task Run(Func<IOperationFactory, Task<QVoid>> operation)
        {
            await operation(simulator);
        }

        public bool Advance() => advanceEvent.Set();

        public async Task ReplayHistory(IClientProxy client)
        {
            foreach (var (method, args) in history)
            {
                await client.SendCoreAsync(method, args);
            }
        }

        private T GetService<T>() =>
            (T) host.Services.GetService(typeof(T));

        private async Task BroadcastAsync(string method, params object[] args)
        {
            history.Add((method, args));
            await context.Clients.All.SendCoreAsync(method, args);
        }

        private async Task WaitForAdvance() => await Task.Run(() =>
        {
            advanceEvent.Reset();
            advanceEvent.WaitOne();
        });

        private void OnOperationStartHandler(ICallable operation, IApplyData arguments)
        {
            var variant = operation.Variant == OperationFunctor.Body ? "" : operation.Variant.ToString();
            var qubits = arguments.Qubits?.Select(q => q.Id).ToArray() ?? Array.Empty<int>();
            BroadcastAsync("OperationStarted", $"{variant} {operation.Name}", qubits).Wait();
            WaitForAdvance().Wait();
        }

        private void OnOperationEndHandler(ICallable operation, IApplyData result)
        {
            var stateDumper = new StateDumper(simulator);
            stateDumper.Dump();
            BroadcastAsync("OperationEnded", result.Value, stateDumper.GetAmplitudes()).Wait();
            WaitForAdvance().Wait();
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
            return base.Dump();
        }

        public Complex[] GetAmplitudes() => amplitudes.ToArray();
    }
}
