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
        public class SignalRMeasure : Intrinsic.Measure
        {
            private VisualizationSimulator simulator;
            private readonly ICallable<(IQArray<Pauli>, IQArray<Qubit>), Result> original;
            public SignalRMeasure(VisualizationSimulator m) : base(m)
            {
                simulator = m;
                original = (Factory as VisualizationSimulator)
                    .underlyingSimulator
                    .Get<ICallable<(IQArray<Pauli>, IQArray<Qubit>), Result>, Intrinsic.Measure>();
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>), Result> Body => (args) =>
            {
                var (meas, register) = args;
                // Run the original Measure as well.
                var result = original.Apply(args);
                simulator.AnnounceOperation("Measure", (meas, register.Select(q => q.Id)), result).Wait();
                return result;
            };

        }
    }
}
