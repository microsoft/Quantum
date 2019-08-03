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
using System.Threading;
using System.Threading.Tasks;

namespace vis_sim
{
    public class VisualDebugger
    {
        internal readonly QuantumSimulator simulator;
        private readonly IWebHost host;
        private readonly IHubContext<VisualizationHub> context;
        private readonly ManualResetEvent advanceEvent = new ManualResetEvent(true);
        private readonly IList<(string method, object[] args)> history = new List<(string, object[])>();

        public VisualDebugger(QuantumSimulator simulator)
        {
            simulator.OnOperationStart += OnOperationStartHandler;
            simulator.OnOperationEnd += OnOperationEndHandler;
            this.simulator = simulator;

            host = WebHost
                .CreateDefaultBuilder()
                .UseStartup<Startup>()
                .ConfigureServices(services => {
                    // Register ourselves as a service so that the different
                    // hubs and controllers can use us through DI.
                    services.AddSingleton(typeof(VisualDebugger), this);
                })
                .UseUrls("http://localhost:5000")
                .UseKestrel()
                .Build();
            new Thread(() => host.Run()).Start();

            context = GetService<IHubContext<VisualizationHub>>();
        }

        public async Task Run(Func<IOperationFactory, Task<QVoid>> operation)
        {
            await WaitForAdvance();
            await operation(simulator);
        }

        public bool Advance() => advanceEvent.Set();

        public async Task ReplayHistory(IClientProxy client)
        {
            foreach (var (method, args) in history)
                await client.SendCoreAsync(method, args);
        }

        private T GetService<T>() => (T) host.Services.GetService(typeof(T));

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
            var qubits = arguments.Qubits?.Select(q => q.Id).ToArray() ?? Array.Empty<int>();
            BroadcastAsync("operationStarted", GetOperationDisplayName(operation), qubits).Wait();
            WaitForAdvance().Wait();
        }

        private void OnOperationEndHandler(ICallable operation, IApplyData result)
        {
            var state = new StateController(this).GetSimulatorState().GetAwaiter().GetResult();  // TODO
            BroadcastAsync("operationEnded", result.Value, state.Value).Wait();
            WaitForAdvance().Wait();
        }

        private static string GetOperationDisplayName(ICallable operation)
        {
            switch (operation.Variant)
            {
                case OperationFunctor.Body: return operation.Name;
                case OperationFunctor.Adjoint: return $"Adjoint {operation.Name}";
                case OperationFunctor.Controlled: return $"Controlled {operation.Name}";
                case OperationFunctor.ControlledAdjoint: return $"Controlled Adjoint {operation.Name}";
                default: throw new ArgumentException("Invalid operation variant", nameof(operation));
            }
        }
    }
}
