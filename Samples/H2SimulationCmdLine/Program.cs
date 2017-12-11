// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.H2Simulation
{
    class Program
    {
        static void Main(string[] args)
        {

            // We begin by making an instance of the simulator that we will use to run our Q# code.
            using (var qsim = new QuantumSimulator()) {

                #region Basic Definitions

                // Next, we give C# names to each operation defined in Q#.
                // In doing so, we ask the simulator to give us each operation
                // so that it has an opportunity to override operation definitions.
                var H2EstimateEnergyRPE = qsim.Get<H2EstimateEnergyRPE, H2EstimateEnergyRPE>();
                var H2BondLengths = qsim.Get<H2BondLengths, H2BondLengths>();

                #endregion

                #region Calling into Q#

                // To call a Q# operation that takes unit `()` as its input, we need to grab
                // the QVoid.Instance value.
                var bondLengths = H2BondLengths.Body.Invoke(QVoid.Instance);

                // In Q#, we defined the operation that performs the actual estimation;
                // we can call it here, giving a structure tuple that corresponds to the
                // C# ValueTuple that it takes as its input. Since the Q# operation
                // has type (idxBondLength : Int, nBitsPrecision : Int, trotterStepSize : Double) => (Double),
                // we pass the index along with that we want six bits of precision and
                // step size of 1.
                //
                // The result of calling H2EstimateEnergyRPE is a Double, so we can minimize over
                // that to deal with the possibility that we accidently entered into the excited
                // state instead of the ground state of interest.
                Func<int, Double> estAtBondLength = (idx) => Enumerable.Min(
                    from idxRep in Enumerable.Range(0, 3)
                    select H2EstimateEnergyRPE.Body.Invoke((idx, 6, 1.0))
                );

                // We are now equipped to run the Q# simulation at each bond length
                // and print the answers out to the console.
                foreach (var idxBond in Enumerable.Range(0, 54))
                {
                    System.Console.WriteLine($"Estimating at bond length {bondLengths[idxBond]}:");
                    var est = estAtBondLength(idxBond);
                    System.Console.WriteLine($"\tEst: {est}\n");
                }

                #endregion

            }

            System.Console.WriteLine("Press Enter to exit...");
            System.Console.ReadLine();
        }
    }
}
