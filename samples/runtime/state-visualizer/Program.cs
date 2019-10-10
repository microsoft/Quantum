// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.StateVisualizer
{
    /// <summary>
    /// Runs the Q# state visualizer. See the README for more information, including instructions on how to build and
    /// run this program.
    /// </summary>
    internal class Program
    {
        private static void Main(string[] args)
        {
            var visualizer = new StateVisualizer(new QuantumSimulator());
            try
            {
                visualizer.Run(QsMain.Run).Wait();
            }
            catch (AggregateException aggregate)
            {
                aggregate.Flatten().Handle(ex => ex is TaskCanceledException);
            }
        }
    }
}
