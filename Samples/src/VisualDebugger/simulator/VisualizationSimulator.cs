// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Intrinsic = Microsoft.Quantum.Intrinsic;
using static System.Math;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Extensions.Hosting;
using Microsoft.AspNetCore.Hosting;
using System.Threading;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;

namespace vis_sim
{
    public partial class VisualizationSimulator : SimulatorBase
    {
        internal readonly QuantumSimulator underlyingSimulator;
        private readonly IWebHost host;

        private readonly IHubContext<VisualizationHub> context;
        private readonly AdvanceEvent advance;

        private readonly ManualResetEvent readyToProceed = new ManualResetEvent(true);

        public VisualizationSimulator()
        {
            underlyingSimulator = new QuantumSimulator();

            host = WebHost
                .CreateDefaultBuilder()
                .UseStartup<Startup>()
                .ConfigureServices(services => {
                    // Register ourselves as a service so that the different
                    // hubs and controllers can use us through DI.
                    services.AddSingleton(typeof(VisualizationSimulator), this);
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
        }

        private T GetService<T>() => ((T) host.Services.GetService(typeof(T)));

        /// <summary>
        /// The name of an instance of this simulator.
        /// </summary>
        public override string Name => "Visualization Simulator";

        private Task BroadcastAsync(string method, object arg) =>
            context.Clients.All.SendAsync(method, arg);

        private Task BroadcastAsync(string method, object arg1, object arg2) =>
            context.Clients.All.SendAsync(method, arg1, arg2);

        private Task BroadcastAsync(string method, object arg1, object arg2, object arg3) =>
            context.Clients.All.SendAsync(method, arg1, arg2, arg3);

        private async Task UserInput()
        {
            await Task.Run(() => {
                advance.WaitForUser();
            });
        }

        private async Task AnnounceOperation(string operationName, object arguments = null, object result = null)
        {
            await BroadcastAsync("operationCalled", operationName, arguments ?? QVoid.Instance, result ?? QVoid.Instance);
            await UserInput();
        }


        /// <summary>
        /// Implementation of the (internal) Release operation for the Toffoli simulator.
        /// </summary>
        public class VSRelease : Intrinsic.Release
        {
            internal VisualizationSimulator simulator { get; private set; }

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public VSRelease(VisualizationSimulator m) : base(m)
            {
                simulator = m;
            }

            public override void Apply(Qubit q)
            {
                simulator.underlyingSimulator.QubitManager.Release(q);
                simulator.AnnounceOperation("Release", q.Id).Wait();
            }
            public override void Apply(IQArray<Qubit> qs)
            {
                simulator.underlyingSimulator.QubitManager.Release(qs);
                simulator.AnnounceOperation("Release", qs.Select(q => q.Id).ToArray()).Wait();
            }
        }

        public class VSAllocate : Intrinsic.Allocate
        {
            internal VisualizationSimulator simulator { get; private set; }

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public VSAllocate(VisualizationSimulator m) : base(m)
            {
                simulator = m;
            }

            public override Qubit Apply()
            {
                var q = simulator.underlyingSimulator.QubitManager.Allocate();
                simulator.AnnounceOperation("Allocate", QVoid.Instance).Wait();
                return q;
            }
            public override IQArray<Qubit> Apply(long count)
            {
                var qs = simulator.underlyingSimulator.QubitManager.Allocate(count);
                simulator.AnnounceOperation("Allocate", count).Wait();
                return qs;
            }
        }

        // TODO: announce borrow/return as well.

        public class VSBorrow : Intrinsic.Borrow
        {
            internal VisualizationSimulator simulator { get; private set; }

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public VSBorrow(VisualizationSimulator m) : base(m)
            {
                simulator = m;
            }

            public override Qubit Apply() =>
                simulator.underlyingSimulator.QubitManager.Borrow();
            public override IQArray<Qubit> Apply(long count) =>
                simulator.underlyingSimulator.QubitManager.Borrow(count);
        }

        public class VSReturn : Intrinsic.Return
        {
            private VisualizationSimulator simulator;

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public VSReturn(VisualizationSimulator m) : base(m)
            {
                simulator = m;
            }

            public override void Apply(Qubit q) =>
                simulator.underlyingSimulator.QubitManager.Return(q);
            public override void Apply(IQArray<Qubit> qs) =>
                simulator.underlyingSimulator.QubitManager.Return(qs);
        }
    }
}
