// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using System;
using System.Linq;
using System.Threading.Tasks;

using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.H2Simulation
{
    class Program
    {
        static async Task Main(string[] args)
        {
            // We begin by making an instance of the simulator that we will use to run our Q# code.
            using (var qsim = new QuantumSimulator()) {

                // We call the Q# function H2BondLengths to get the bond lengths at which we want to
                // estimate the energy.
                var bondLengths = await H2BondLengths.Run(qsim);

                // In Q#, we defined the operation that performs the actual estimation;
                // we can call it here, giving a structure tuple that corresponds to the
                // C# ValueTuple that it takes as its input. Since the Q# operation
                // has type (idxBondLength : Int, nBitsPrecision : Int, trotterStepSize : Double) => (Double),
                // we pass the index along with that we want six bits of precision and
                // step size of 1.
                //
                // The result of calling H2EstimateEnergyRPE is a Double, so we can minimize over
                // that to deal with the possibility that we accidentally entered into the excited
                // state instead of the ground state of interest.
                Func<int, Double> estAtBondLength = (idx) => Enumerable.Min(
                    from idxRep in Enumerable.Range(0, 3)
                    select H2EstimateEnergyRPE.Run(qsim, idx, 6, 1.0).Result
                );

                // We are now equipped to run the Q# simulation at each bond length
                // and print the answers out to the console.
                foreach (var idxBond in Enumerable.Range(0, 54))
                {
                    System.Console.WriteLine($"Estimating at bond length {bondLengths[idxBond]}:");
                    var est = estAtBondLength(idxBond);
                    System.Console.WriteLine($"\tEst: {est}\n");
                }

            }

            Console.WriteLine("Press Enter to continue...");
            Console.ReadLine();
        }
    }
}
