// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using Microsoft.Quantum.Simulation.QuantumProcessor;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Samples
{
    public partial class QpicSimulator : QuantumProcessorDispatcher {
        // Implementation of the `Barrier` operation for the QpicSimulator
        public class BarrierImpl : Barrier {
            private QpicProcessor processor;

            public BarrierImpl(QpicSimulator m) : base(m) {
                processor = (QpicProcessor)m.QuantumProcessor;
            }

            // Adds a BARRIER qpic command to all open scopes.
            public override Func<QVoid, QVoid> Body => _ => {
                processor.AddCommand("BARRIER");
                return QVoid.Instance;
            };
        }
    }
}
