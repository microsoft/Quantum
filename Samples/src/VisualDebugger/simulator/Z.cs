// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Quantum.Simulation.Core;
using Intrinsic = Microsoft.Quantum.Intrinsic;

namespace vis_sim
{
    public partial class VisualizationSimulator
    {
        public class SignalRZ : Intrinsic.Z
        {
            private VisualizationSimulator simulator;
            private readonly IUnitary<Qubit> original;
            public SignalRZ(VisualizationSimulator m) : base(m)
            {
                simulator = m;
                original = (Factory as VisualizationSimulator)
                    .underlyingSimulator
                    .Get<IUnitary<Qubit>, Intrinsic.Z>();
            }

            public override Func<Qubit, QVoid> Body => (target) =>
            {
                // Run the original Z as well.
                original.Apply(target);
                simulator.AnnounceOperation("Z", target.Id).Wait();
                return QVoid.Instance;
            };


            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => (args) =>
            {
                var (controls, target) = args;
                // Run the original Z as well.
                original.Controlled.Apply(args);
                simulator.AnnounceOperation("Controlled Z", (controls.Select(q => q.Id).ToArray(), target.Id)).Wait();
                return QVoid.Instance;
            };
        }
    }
}
