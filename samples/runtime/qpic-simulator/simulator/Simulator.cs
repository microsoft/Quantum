// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using Microsoft.Quantum.Simulation.QuantumProcessor;

namespace Microsoft.Quantum.Samples
{
    public partial class QpicSimulator : QuantumProcessorDispatcher {
        public QpicSimulator() : base(new QpicProcessor()) {}
    }
}
