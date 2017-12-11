// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Samples.PhaseEstimation
{
    class Program
    {
        public static void Pause()
        {
            System.Console.WriteLine("\n\nPress any key to continue...\n\n");
            System.Console.ReadKey();
        }
        static void Main(string[] args)
        {

            #region Setup

            // We begin by defining a quantum simulator to be our target
            // machine.
            var sim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true);

            // Next, we pick an arbitrary value for the eigenphase to be
            // estimated. Note that we have assumed in the Q# operations that
            // the prior for the phase φ is supported only on the interval
            // [0, 1], so you might get inconsistent answers if you violate
            // that constraint. Try it out!
            const Double eigenphase = 0.344;

            #endregion

            #region Phase Estimation as a Likelihood Function
            // In this region, we run the PhaseEstimationIteration()
            // operation defined in the associated Q# file. That operation
            // checks that the iterative phase estimation step has the right
            // likelihood function.

            System.Console.WriteLine("Phase Estimation Likelihood Check:");
            PhaseEstimationIterationCheck.Run(sim).Wait();
            Pause();

            #endregion

            #region
            // Next, we run the BayesianPhaseEstiamtionSample operation
            // defined in Q#. This operation estimates the phase φ using an
            // explicit grid approximation to the Bayesian posterior.

            System.Console.WriteLine("Bayesian Phase Estimation w/ Explicit Grid:");
            var est = BayesianPhaseEstimationSample.Run(sim, eigenphase).Result;
            System.Console.WriteLine($"Expected {eigenphase}, estimated {est}.");
            Pause();

            #endregion

            #region
            // Finally, for comparison, we also use the random walk algorithm
            // for Bayesian phase estimation provided with the Q# canon.

            System.Console.WriteLine("Bayesian Phase Estimation w/ Random Walk:");
            est = BayesianPhaseEstimationCanonSample.Run(sim, eigenphase).Result;
            System.Console.WriteLine($"Expected {eigenphase}, estimated {est}.");
            System.Console.ReadLine();
            #endregion
            
            System.Console.WriteLine("\n\nPress Enter to exit...\n\n");
            System.Console.ReadLine();

        }
    }
}
