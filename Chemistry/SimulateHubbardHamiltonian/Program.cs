// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#region Using Statements
// We will need several different libraries in this sample.
// Here, we expose these libraries to our program using the
// C# "using" statement, similar to the Q# "open" statement.

// We will use the data model implemented by the Quantum Development Kit chemistry
// libraries. This model defines what a fermionic Hamiltonian is, and how to
// represent Hamiltonians on disk.
using Microsoft.Quantum.Chemistry.OrbitalIntegrals;
using Microsoft.Quantum.Chemistry.Fermion;
using Microsoft.Quantum.Chemistry.QSharpFormat;

// To perform the simulation, we'll use the full state simulator provided with
// the Quantum Development Kit.
using Microsoft.Quantum.Simulation.Simulators;

// The System namespace provides a number of useful built-in
// types and methods that we'll use throughout this sample.
using System;

// We use this for convenience methods for manipulating arrays.
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
            var hubbardOrbitalIntegralHamiltonian = new OrbitalIntegralHamiltonian();

            foreach (var i in Enumerable.Range(0, nSites))
            {
                hubbardOrbitalIntegralHamiltonian.Add(new OrbitalIntegral(new[] { i, (i + 1) % nSites }, -t));
                hubbardOrbitalIntegralHamiltonian.Add(new OrbitalIntegral(new[] { i, i, i, i }, u));
            }

            // Create fermion representation of Hamiltonian
            // In this case, we use the spin-orbital to integer
            // indexing convention `x = orbitalIdx + spin * nSites`; as it 
            // minimizes the length of Jordan–Wigner strings
            var hubbardFermionHamiltonian = hubbardOrbitalIntegralHamiltonian.ToFermionHamiltonian(IndexConvention.HalfUp);

            #endregion


            #region Estimating energies by simulating quantum phase estimation
            // Create Jordan–Wigner representation of Hamiltonian
            var jordanWignerEncoding = hubbardFermionHamiltonian.ToPauliHamiltonian();

            // Create data structure to pass to QSharp.
            var qSharpData = jordanWignerEncoding.ToQSharpFormat().Pad();

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
