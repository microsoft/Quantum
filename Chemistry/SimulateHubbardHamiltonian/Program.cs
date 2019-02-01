// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#region Using Statements
// We will need several different libraries in this sample.
// Here, we expose these libraries to our program using the
// C# "using" statement, similar to the Q# "open" statement.

// We will use the data model implemented by the Quantum Development Kit Chemistry
// Libraries. This model defines what a fermionic Hamiltonian is, and how to
// represent Hamiltonians on disk.
using Microsoft.Quantum.Chemistry;

// To count gates, we'll use the trace simulator provided with
// the Quantum Development Kit.
using Microsoft.Quantum.Simulation.Simulators;

// The System namespace provides a number of useful built-in
// types and methods that we'll use throughout this sample.
using System;

// The System.Diagnostics namespace provides us with the
// Stopwatch class, which is quite useful for measuring
// how long each gate counting run takes.
using System.Diagnostics;

// The System.Collections.Generic library provides many different
// utilities for working with collections such as lists and dictionaries.
using System.Collections.Generic;

// We use the logging library provided with .NET Core to handle output
// in a robust way that makes it easy to turn on and off different messages.
using Microsoft.Extensions.Logging;

// We use this for convnience functions for manipulation arrays.
using System.Linq;
#endregion

namespace Microsoft.Quantum.Chemistry.Samples.Hubbard
{
    class Program
    {
        static void Main(string[] args)
        {
            //////////////////////////////////////////////////////////////////////////
            // Introduction //////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////

            // In this example, we will estimate the ground state energy of 
            // 1D Hubbard Hamiltonian using the quantum chemistry library. 

            // The 1D Hubbard model has `n` sites. Let `i` be the site index, 
            // `s` = 1,0 be the spin index, where 0 is up and 1 is down, `t` be the 
            // hopping coefficient, `u` the repulsion coefficient, and aᵢₛ the fermionic 
            // annihilation operator on the fermion indexed by `(i,s)`. The Hamiltonian 
            // of this model is
            //
            //     H ≔ - t Σᵢ (a†ᵢₛ aᵢ₊₁ₛ + a†ᵢ₊₁ₛ aᵢₛ) + u Σᵢ a†ᵢ₀ a†ᵢ₁ aᵢ₁ aᵢ₀
            //
            // Note that we use closed boundary conditions.

            #region Building the Hubbard Hamiltonian through orbital integrals

            var t = 0.2; // hopping coefficient
            var u = 1.0; // repulsion coefficient
            var nSites = 6; // number of sites;
            // Construct Hubbard Hamiltonian
            var hubbardHamiltonian = new FermionHamiltonian(nOrbitals: nSites, nElectrons: nSites);

            foreach (var i in Enumerable.Range(0, nSites))
            {
                hubbardHamiltonian.AddFermionTerm(new OrbitalIntegral(new[] { i, (i + 1) % nSites }, - t));
                hubbardHamiltonian.AddFermionTerm(new OrbitalIntegral(new[] { i, i, i, i }, u));
            }

            // Let us verify that both Hamiltonians are identical
            hubbardHamiltonian.SortAndAccumulate();
            Console.WriteLine($"Hubbard Hamiltonian:");
            Console.WriteLine(hubbardHamiltonian + "\n");
            #endregion


            #region Estimating energies by simulating quantum phase estimation
            var jordanWignerEncoding = JordanWignerEncoding.Create(hubbardHamiltonian);
            var qSharpData = jordanWignerEncoding.QSharpData();

            Console.WriteLine($"Estimate Hubbard Hamiltonian energy:");
            // Bits of precision in phase estimation.
            var bits = 7;

            // Repetitions to find minimum energy.
            var reps = 5;

            // Trotter step size
            var trotterStep = 0.5;

            using (var qsim = new QuantumSimulator())
            {
                
                for (int i = 0; i < reps; i++)
                {
                    // EstimateEnergyByTrotterization
                    // Name shold make clear that it does it by trotterized
                    var (phaseEst, energyEst) = GetEnergy.Run(qsim, qSharpData, bits, trotterStep).Result;

                    Console.WriteLine($"Rep #{i}: Energy estimate: {energyEst}; Phase estimate: {phaseEst}");
                }
                
            }

            Console.WriteLine("Press Enter to continue...");
            if (System.Diagnostics.Debugger.IsAttached)
            {
                Console.ReadLine();
            }
            #endregion
        }
    }
}
