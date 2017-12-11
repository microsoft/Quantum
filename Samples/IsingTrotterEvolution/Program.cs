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

namespace Microsoft.Quantum.Samples.Ising
{
    class Program
    {
        static void Main(string[] args)
        {

            #region Basic Definitions

            // We start by loading the simulator that we will use to run our Q# operations.
            var qsim = new QuantumSimulator();

            // For this example, we'll consider a chain of five sites, each one of which
            // is simulated using a single qubit.
            var nSites = 7;

            // We'll evolve for times ranging from t = 0.1 to t = 1.0, in
            // steps of 0.1 where the units are implicitly fixed by the units
            // of the Hamiltonian itself.
            int nTimeSteps = 10;
            var deltaTime = 0.1;

            // We choose the order of the Trotter–Suzuki integrator.
            var trotterOrder = 2;

            // We should choose the step size of each Trotter step to be
            // small.
            var timeStep = 0.1;

            // We will perform a number of repeats to collect statistics
            var repeats = 100;

            // For diagnostic purposes, before we proceed to the next step, we'll print
            // out a description of the parameters we just defined.
            Console.WriteLine("Ising model spin excitation:");
            Console.WriteLine($"\t{nSites} sites\n\t{(nTimeSteps) * deltaTime} max simulation time\n\t{deltaTime} time increment\n\t{timeStep} time step \n");

            #endregion

            #region Calling into Q#

            // Now that we've defined everything we need, let's proceed to
            // actually call the simulator. As we only receive a single bit of
            // data each time on a single-site measurement, we repeat a number
            // of times to collect statistics.
            foreach (var idxTimeStep in Enumerable.Range(0, nTimeSteps + 1))
            {
                // the simulation time is set here and we print this out.
                var time = idxTimeStep * (double) deltaTime;
                Console.Write($"Evolution for {time} time.\t ");

                // We initialize an array that stores counts of measurement
                // result for each site
                double[] counts = new double[nSites];

                foreach (var idxAttempt in Enumerable.Range(0, repeats))
                {

                    // Each operation has a static method called Run which takes a simulator as
                    // an argument, along with all the arguments defined by the operation itself.
                    var task = Ising1DExcitationCorrelation.Run(qsim, nSites, time, trotterOrder, timeStep);



                    // Since this method is asynchronous, we need to explicitly wait for the result back
                    // from the simulator. We do this by getting the Result property. To turn the result
                    // back into a conventional .NET array, we finish by calling ToArray().
                    var data = task.Result.ToArray();

                    // We can now compute the magnetization entirely in C# code, since data is
                    // an array of the classical measurement results observed back from our simulation.
                    foreach (var idxSite in Enumerable.Range(0, nSites))
                    {
                        counts[idxSite] += (data[idxSite] == Result.One ? 1.0 : -1.0);
                    }
                }

                Console.Write($"Sum of magnetization: ");
                foreach (var item in counts)
                {
                    Console.Write($"{item} ");
                }
                Console.Write($"\t after {repeats} repeats.\n");
            }
            Console.ReadLine();

            #endregion

        }
    }
}
