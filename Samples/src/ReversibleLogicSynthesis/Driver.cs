// Author: Mathias Soeken, EPFL (Mail: mathias.soeken@epfl.ch)
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.ReversibleLogicSynthesis
{
    class Driver
    {
        static void Main(string[] args)
        {
            var sim = new QuantumSimulator();

            var perm = new long[] { 0, 2, 3, 5, 7, 1, 4, 6 };
            var res = SimulatePermutation.Run(sim, new QArray<long>(perm)).Result;
            System.Console.WriteLine($"Does circuit realize permutation: {res}");

            for (var shift = 0; shift < perm.Length; ++shift)
            {
                var measured_shift = FindHiddenShift.Run(sim, new QArray<long>(perm), shift).Result;
                System.Console.WriteLine($"Applied shift = {shift}   Measured shift: {measured_shift}");
            }
        }
    }
}