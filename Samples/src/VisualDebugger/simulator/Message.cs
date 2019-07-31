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
        public class SignalRMessage : Intrinsic.Message
        {
            private VisualizationSimulator simulator;
            public SignalRMessage(VisualizationSimulator m) : base(m)
            {
                simulator = m;
            }

            public override Func<string, QVoid> Body => (message) =>
            {
                // Run the original Message as well.
                (Factory as VisualizationSimulator)
                    .underlyingSimulator
                    .Get<ICallable<string, QVoid>, Intrinsic.Message>()
                    .Apply(message);
                simulator.AnnounceOperation("Message", message).Wait();
                return QVoid.Instance;
            };
        }
    }
}
