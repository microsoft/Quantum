// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.VisualDebugger
{
    /// <summary>
    /// Runs the Q# visual debugger. See the README for more information, including instructions on how to build and run
    /// this program.
    /// </summary>
    internal class Program
    {
        private static void Main(string[] args)
        {
            var debugger = new VisualDebugger(new QuantumSimulator());
            debugger.Run(QsMain.Run).Wait();
        }
    }
}
