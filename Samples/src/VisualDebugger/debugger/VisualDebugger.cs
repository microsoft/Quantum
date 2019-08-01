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
        private readonly AdvanceEvent advance;

        public VisualDebugger(QuantumSimulator simulator)
        {
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
            var serverThread = new Thread(
                () => host.Run()
            );
            serverThread.Start();

            context = GetService<IHubContext<VisualizationHub>>();
            advance = GetService<AdvanceEvent>();

            this.simulator = simulator;
            this.simulator.OnOperationStart += OnOperationStartHandler;
            this.simulator.OnOperationEnd += OnOperationEndHandler;
        }

        public async Task Run(Func<IOperationFactory, Task<QVoid>> operation)
        {
            await UserInput();
            await operation(simulator);
        }

        private T GetService<T>() => ((T) host.Services.GetService(typeof(T)));

        private Task BroadcastAsync(string method, object arg) =>
            context.Clients.All.SendAsync(method, arg);

        private Task BroadcastAsync(string method, object arg1, object arg2) =>
            context.Clients.All.SendAsync(method, arg1, arg2);

        private async Task UserInput()
        {
            await Task.Run(() => {
                advance.WaitForUser();
            });
        }

        private void OnOperationStartHandler(ICallable operation, IApplyData arguments)
        {
            var qubits = arguments.Qubits?.Select(q => q.Id).ToArray() ?? Array.Empty<int>();
            BroadcastAsync("operationStarted", GetOperationDisplayName(operation), qubits).Wait();
            UserInput().Wait();
        }

        private void OnOperationEndHandler(ICallable operation, IApplyData result)
        {
            BroadcastAsync("operationEnded", result.Value).Wait();
            UserInput().Wait();
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
