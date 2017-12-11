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

namespace Microsoft.Quantum.Samples.Hubbard
{
    class Program
    {
        static void Main(string[] args)
        {

            #region Basic Definitions
            
             // We start by loading the simulator that we will use to run our Q# operations.
             var qsim = new QuantumSimulator();

            // For this example, we'll consider a loop of siz sites, each one of which
            // is simulated using two qubits.
            var nSites = 6;

            // Let us choose a repulsion term somewhat larger than the hopping term 
            // to favor single-site occupancy. 
            var uCoefficient = 1.0;
            var tCoefficient = 0.2;

            // We need to choose the number of bits of precision in phase estimation. Bear in mind
            // that this is bits of precision before rescaling by the trotterStepSize. A smaller
            // trotterStepSize would require more bits of precision to obtain the same absolute 
            // accuracy.
            var bitsPrecision = 7;

            // We choose a small trotter step size for improved simulation error.
            // This should be at least small enough to avoid aliasing of estimated phases.
            var trotterStepSize = 0.5;
            
            // For diagnostic purposes, before we proceed to the next step, we'll print
            // out a description of the parameters we just defined.
            Console.WriteLine("Hubbard model ground state energy estimation:");
            Console.WriteLine(  $"\t{nSites} sites\n" +
                                $"\t{uCoefficient} repulsion term coefficient\n" +
                                $"\t{tCoefficient} hopping term coefficient\n" +
                                $"\t{bitsPrecision} bits of precision\n" +
                                $"\t{Math.Pow(2.0, -1.0 * (double) bitsPrecision) / trotterStepSize} energy estimate error from phase estimation alone\n" +
                                $"\t{trotterStepSize} time step");

            #endregion

            #region Calling into Q#

            // Now that we've defined everything we need, let's proceed to
            // actually call the simulator. Since there's a finite chance of successfully
            // projecting onto the ground state, we will call our new operation through
            // the simulator several times, reporting the estimated energy after each attempt.

            foreach (var idxAttempt in Enumerable.Range(0, 10))
            {
                // Each operation has a static method called Run which takes a simulator as
                // an argument, along with all the arguments defined by the operation itself.
                var task = HubbardAntiFerromagneticEnergyEsimate.Run(qsim, nSites, tCoefficient, uCoefficient, bitsPrecision, trotterStepSize);
                // Since this method is asynchronous, we need to explicitly wait for the result back
                // from the simulator. We do this by getting the Result property. 
                var energyEst = task.Result;

                // This result is a double and may be printed directly to the console.

                Console.WriteLine($"Energy estimated in attempt {idxAttempt}: {energyEst}");

            }

            #endregion

            Console.ReadLine();
        }
    }
}
