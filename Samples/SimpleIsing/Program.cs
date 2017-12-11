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

namespace Microsoft.Quantum.Samples.SimpleIsing
{
    class Program
    {
        static void Main(string[] args)
        {

            #region Basic Definitions

            // We start by loading the simulator that we will use to run our Q# operations.
            var qsim = new QuantumSimulator();

            // For this example, we'll consider a chain of twelve sites, each one of which
            // is simulated using a single qubit.
            var nSites = 12;

            // We'll sweep from the transverse to the final Hamiltonian in time t = 10.0,
            // where the units are implicitly fixed by the units of the Hamiltonian itself.
            var sweepTime = 10.0;

            // Finally, we'll then decompose the time evolution down into small steps.
            // During each step, we'll perform each term in the Hamiltonian individually.
            // By the Trotter–Suzuki decomposition (also implemented in the canon), this
            // approximates the complete Hamiltonian for the entire sweep time.
            //
            // If we choose the evolution time carefully, we should prepare the ground
            // state of our final Hamiltonian (see the references in README.md for more
            // details).
            var timeStep = 0.1;

            // For diagnostic purposes, before we proceed to the next step, we'll print
            // out a description of the parameters we just defined.
            Console.WriteLine("Ising model ground state preparation:");
            Console.WriteLine($"\t{nSites} sites\n\t{sweepTime} sweep time\n\t{timeStep} time step");

            #endregion

            #region Calling into Q#

            // Now that we've defined everything we need, let's proceed to
            // actually call the simulator. Since there's a finite chance of successfully
            // preparing the ground state, we will call our new operation through
            // the simulator several times, reporting the magnetization after each attempt.

            foreach (var idxAttempt in Enumerable.Range(0, 100))
            {
                // Each operation has a static method called Run which takes a simulator as
                // an argument, along with all the arguments defined by the operation itself.
                var task = Ising.Run(qsim, nSites, sweepTime, timeStep);

                // Since this method is asynchronous, we need to explicitly
                // wait for the result back from the simulator. We do this by
                // getting the Result property. To turn the result back into a
                // conventional .NET array, we finish by calling ToArray() and
                // using a C# lambda function to convert each Result into a
                // floating point number representing the observed spin.
                var data = task.Result.ToArray().Select((result) => result == Result.One ? 0.5 : -0.5);

                // We can now compute the magnetization entirely in C# code,
                // since data is an array of the classical measurement results
                // observed back from our simulation.
                var magnetization = data.Sum();

                Console.WriteLine($"Magnetization observed in attempt {idxAttempt}: {magnetization}");

            }

            #endregion

            Console.ReadLine();
        }
    }
}
