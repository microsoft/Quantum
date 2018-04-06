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

            QArray<long> perm = new QArray<long> { 0, 2, 3, 5, 7, 1, 4, 6 };
            var res = PermutationSimulation.Run(sim, perm).Result;
            System.Console.WriteLine($"Does circuit realize permutation: {res}");

            for (var shift = 0; shift < perm.Length; ++shift)
            {
                var measured_shift = HiddenShiftProblem.Run(sim, perm, shift).Result;
                System.Console.WriteLine($"Applied shift = {shift}   Measured shift: {measured_shift}");
            }
        }
    }
}