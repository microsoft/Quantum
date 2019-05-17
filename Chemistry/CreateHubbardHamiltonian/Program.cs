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
using Microsoft.Quantum.Chemistry.OrbitalIntegrals;
using Microsoft.Quantum.Chemistry.Fermion;

// To count gates, we'll use the trace simulator provided with
// the Quantum Development Kit.
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

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

            // In this example, we will create a representation of a 
            // 1D Hubbard Hamiltonian using the quantum chemistry library. 
            // This representation allows one to easily simulate Hamiltonian
            // time-evolution and obtain the cost of simulation.


            // The 1D Hubbard model has `n` sites. Let `i` be the site index, 
            // `s` = 1,0 be the spin index, where 0 is up and 1 is down, `t` be the 
            // hopping coefficient, `u` the repulsion coefficient, and aᵢₛ the fermionic 
            // annihilation operator on the fermion indexed by `(i,s)`. The Hamiltonian 
            // of this model is
            //
            //     H ≔ - t/2 Σᵢ (a†ᵢₛ aᵢ₊₁ₛ + a†ᵢ₊₁ₛ aᵢₛ) + u Σᵢ a†ᵢ₀ a†ᵢ₁ aᵢ₁ aᵢ₀
            //
            // Note that we use closed boundary conditions.

            // Contents:
            // - Spin-orbital representation
            // - Hamiltonian term representation
            // - Hamiltonian representation
            // - Building the Hubbard Hamiltonian
            // - Building the Hubbard Hamiltonian through orbital integrals
            // - Jordan-Wigner representation

            #region Spin-orbital representation

            // In the vocabulary of chemistry, the site index is also called the
            // orbital index. Thus a complete description of a fermion index is
            // as spin-orbital. Let us build an example.

            // First, we assign an orbital index, say `5`.
            var orbitalIdx = 5;

            // Second, we assign a spin index. In addition to
            // assigning them up and down integer indices, a good memonic is to
            // label then with a `Spin` enumeration type, say `u` for up and `d`
            // for down.
            var spin = Spin.d;

            // A spin-orbital index is then
            var spinOrbital0 = new SpinOrbital(orbitalIdx, spin);

            // We may also map the composite spin-orbital index into a single integer `x`
            // using the default formula `x = 2 * orbitalIdx + spin;
            var spinOrbital0Int = spinOrbital0.ToInt();

            // Other indexing schemes are possible. For example, we may use the formula
            // `x = orbitalIdx + nOrbitals * spin`
            var spinOrbital0HalfUpInt = spinOrbital0.ToInt(SpinOrbital.IndexConvention.HalfUp);
            
            // Let us print these spin-orbitals to verify they contain the 
            // expected information.
            Console.WriteLine($"Spin-orbital representation:");
            Console.WriteLine($"spinOrbital0: (Orbital, Spin) index: ({spinOrbital0.Orbital},{spinOrbital0.Spin}).");
            Console.WriteLine($"spinOrbital0Int: (2 * Orbital + Spin) index: ({spinOrbital0Int}).");
            Console.WriteLine($"spinOrbital0HalfUpInt: (Orbital + nOrbitals * Spin) index: ({spinOrbital0HalfUpInt}).");
            Console.WriteLine($"");
            #endregion

            #region Hamiltonian term representation
            // Each term in the Hamiltonian is then labelled by an ordered sequence of
            // spin-orbtal indices, and a coefficient. By default, normal-ordering is
            // assumed, meaning that all creation operators are left of all annihilation
            // operators. By default, the number of creation and annihilation operators
            // are also assumed to be equal as chemistry Hamiltonian often conserve
            // particle number.

            // Let us represent the fermion term 0.5 a†ᵢₛ aᵢ₊₁ₛ, where `i` is 5 and `s`
            // is spin up. As mentioned, we require a coefficient

            var coefficient = 0.5;

            // We also require a sequence of spin-orbital indices.
            var spinOrbitalIndices = new[] { (5, Spin.u), (6, Spin.u) };

            // We then convert each element to the `SpinOrbital` type, for instance through
            var spinOrbitals0 = spinOrbitalIndices.Select(arrayElement => new SpinOrbital(arrayElement));

            // Or for instance through
            var spinOrbitals1 = new[] { (1, 0), (1, 1), (1, 1), (1, 0) }.ToSpinOrbitals();

            // These indices may be converted into a list of integers
            var spinOrbitals1Int = spinOrbitals1.ToInts();

            // Alternatively, one may directly create a list of integer indices for the fermion terms.
            var fermionInts = new[] { 10, 12 };
            Console.WriteLine($"spinOrbital0.ToInts() vs. fermionInts({spinOrbitals0.ToInts().SequenceEqual(fermionInts)}).");

            // A fermion term is then
            var fermionTerm0 = new FermionTerm(spinOrbitals0, coefficient);
            var fermionTerm1 = new FermionTerm(spinOrbitals1, 0.123);
            var fermionTerm2 = new FermionTerm(new[] { (2, 0), (2, 1), (2, 1), (2, 0) }.ToSpinOrbitals(), 0.765);

            // Let us print these FermionTerms to see what they contain.
            // Note that Conjugation is an array describing the sequence of creation and annihilation operators.;
            Console.WriteLine($"Hamiltonian term representation:");
            Console.WriteLine($"(Conjugation, Spin-Orbitals, Coefficient): {fermionTerm0}");
            Console.WriteLine($"(Conjugation, Spin-Orbitals, Coefficient): {fermionTerm1}");
            Console.WriteLine($"(Conjugation, Spin-Orbitals, Coefficient): {fermionTerm2}");
            Console.WriteLine($"");

            // As Hamiltonians are Hermitian operators, every non-Hermitian
            // term is assumed to added to its Hermitian conjugate. Thus
            // any sequence of spinOrbitalIndices is treated as equivalent to
            // the same sequence in reverse order. To illustrate,
            var fermionTerm0Reversed = new FermionTerm(spinOrbitals0.Reverse(), coefficient);

            Console.WriteLine($"Fermion terms with reverse spin-orbital indices:");
            Console.WriteLine($"Original term                      : {fermionTerm0}");
            Console.WriteLine($"Reversed spin-orbital sequence term: {fermionTerm0Reversed}");
            Console.WriteLine($"");
            #endregion

            #region Hamiltonian representation 

            // A Hamiltonian is a sum of fermion terms, which we represent through
            var hamiltonian = new FermionHamiltonian();

            // The library provides a number of helpful methods for adding terms to this
            // Hamiltonian. Below, we choose a straightfoward approch where we manually 
            // add terms one by one. For instance, 
            hamiltonian.AddFermionTerm(fermionTerm0);
            hamiltonian.AddFermionTerm(fermionTerm1);
            hamiltonian.AddFermionTerm(fermionTerm2);
            hamiltonian.AddFermionTerm(new[] { (0, 0), (0, 1) }.ToSpinOrbitals(), 1.0);
            hamiltonian.AddFermionTerm(new[] { (0, 0), (0, 1) }.ToSpinOrbitals(), 1.0);
            
            // Let us print this Hamiltonian.
            Console.WriteLine($"Hamiltonian representation:");
            Console.WriteLine(hamiltonian);

            // Note that we have two repeated terms -- we may combine 
            // their coefficients using the method
            hamiltonian.SortAndAccumulate();
            // This also sorts the terms in a certain canonical order.

            // Let us print this sorted Hamiltonian with repeated terms
            // combined/
            Console.WriteLine($"After sorting and accumulating terms:");
            Console.WriteLine(hamiltonian);
            #endregion

            #region Building the Hubbard Hamiltonian 
            // We are now ready to construct the Hubbard Hamiltonian. Let us define
            // a few relevant terms.
            var t = 0.5; // hopping coefficient
            var u = 1.0; // repulsion coefficient
            var nSites = 5; // number of sites;

            // First, initialize a new hamiltonian.
            var hubbardHamiltonian = new FermionHamiltonian();

            // Second, add terms to the hamiltonian.
            for(int i = 0; i < nSites; i++)
            {
                foreach (Spin s in Enum.GetValues(typeof(Spin))) {
                    // Hopping Terms
                    var hoppingTerm = new FermionTerm(new[] { (i, s), ((i + 1) % nSites, s) }.ToSpinOrbitals(), - 0.5 * t);
                    var hoppingTermConjugate = new FermionTerm(new[] { ((i + 1) % nSites, s), (i, s) }.ToSpinOrbitals(), - 0.5 * t);
                    hubbardHamiltonian.AddFermionTerm(hoppingTerm);
                    hubbardHamiltonian.AddFermionTerm(hoppingTermConjugate);
                }
                // Repulsion terms
                var repulsionTerm = new FermionTerm(new[] { (i, Spin.u), (i, Spin.d), (i, Spin.d), (i, Spin.u) }.ToSpinOrbitals(), u);
                hubbardHamiltonian.AddFermionTerm(repulsionTerm);
            }

            // Let us print the Hamiltonian so far.
            Console.WriteLine($"Hubbard Hamiltonian representation:");
            Console.WriteLine(hubbardHamiltonian);

            // We may collect terms and sort them in canonical order as follows.
            hubbardHamiltonian.SortAndAccumulate();
            Console.WriteLine($"After sorting and accumulating Hubbard terms:");
            Console.WriteLine(hubbardHamiltonian);
            #endregion

            #region Building the Hubbard Hamiltonian through orbital integrals 

            // Rather than explicitly specifying the spin indices of each Fermion term, 
            // the Hubbard Hamiltonian may be constructed even more compactly.

            // This is through the use of orbital integrals, which represents the
            // overlap integral between spatial wave-functions, or orbitals. For instance, 
            // a one-electron integral has two spatial indices, and a 
            // two-electron has four spatial indices.
            var oneElectronOrbitalIndices = new[] { 0, 1 };
            var oneElectronCoefficient = 1.0;
            var oneElectronIntegral = new OrbitalIntegral(oneElectronOrbitalIndices, oneElectronCoefficient);

            var twoElectronOrbitalIndices = new[] { 0, 1, 2, 3 };
            var twoElectronCoefficient = 0.123;
            var twoElectronIntegral = new OrbitalIntegral(twoElectronOrbitalIndices, twoElectronCoefficient);

            // Let us print the orbital integrals.
            Console.WriteLine($"Building the Hubbard Hamiltonian through orbital integrals:");
            Console.WriteLine($"(Orbital Indices, Coefficient): {oneElectronIntegral}");
            Console.WriteLine($"(Orbital Indices, Coefficient): {twoElectronIntegral}");


            // Using the following symmetries, the coefficients of various orbital integrals
            // related by permutation of their orbital indices must be identical.
            // - Orbitals are assumed to be real.
            // - Electrons are indistinguishable.
            // We may enumerate over all these symmetries using the following method.
            var twoElectronOrbitalIntegrals = twoElectronIntegral.EnumerateOrbitalSymmetries();

            // Let us print the result.
            Console.WriteLine($"Two-electron orbital integrals with the same coefficient:");
            Console.WriteLine($"Original orbital integral:\n\t{twoElectronIntegral}");
            Console.WriteLine($"Enumerated orbital integrals:\n\t{String.Join("\n\t",twoElectronOrbitalIntegrals)}");

            // This allows us to compactly construct the Hubbard Hamiltonian as follows.
            var anotherHubbardHamiltonian = new FermionHamiltonian();

            foreach(var i in Enumerable.Range(0, nSites))
            {
                anotherHubbardHamiltonian.AddFermionTerm(new OrbitalIntegral(new[] { i, (i+1) % nSites }, - 0.5 * t));
                anotherHubbardHamiltonian.AddFermionTerm(new OrbitalIntegral(new[] { i, i, i, i }, u));
            }
            
            // Let us verify that both Hamiltonians are identical
            anotherHubbardHamiltonian.SortAndAccumulate();
            Console.WriteLine($"Hubbard Hamiltonian constructed using orbital integrals");
            Console.WriteLine(anotherHubbardHamiltonian);
            #endregion

            #region Jordan-Wigner representation 

            // The Jordan-Wigner encoding converts the Fermion Hamiltonian, 
            // expressed in terms of Fermionic operators, to a qubit Hamiltonian,
            // expressed in terms of Pauli matrices. This is an essential step
            // for simulating our constructed Hamiltonians on a qubit quantum
            // computer.
            var jordanWignerEncoding = JordanWignerEncoding.Create(hubbardHamiltonian);

            Console.WriteLine("Press Enter to continue...");
            if (System.Diagnostics.Debugger.IsAttached)
            {
                Console.ReadLine();
            }
            #endregion

            #region Printing to file 
            // We may print the Hamiltonians to file using the following commands.
            Logging.LogPath = "log.txt";
            anotherHubbardHamiltonian.LogSpinOrbitals(LogLevel.Information);
            jordanWignerEncoding.LogSpinOrbitals(LogLevel.Information);
            #endregion
        }
    }
}
