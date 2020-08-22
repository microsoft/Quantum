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

// We use this for convenience methods for manipulating arrays.
using System.Linq;
#endregion

namespace Microsoft.Quantum.Chemistry.Samples.Hydrogen
{
    class Program
    {
        static void Main(string[] args)
        {
            //////////////////////////////////////////////////////////////////////////
            // Introduction //////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////

            // In this example, we will create a spin-orbital representation of the molecular
            // Hydrogen Hamiltonian `H`, given overlap coefficients for its one- and 
            // two - electron integrals.

            // We when perform quantum phase estimation to obtain an estimate of
            // the molecular Hydrogen ground state energy.

            #region Building the Hydrogen Hamiltonian through orbital integrals

            // This representation also has two occupied spin-orbitals.
            var nElectrons = 2;

            // The Coulomb repulsion energy between nuclei is
            var energyOffset = 0.713776188;

            // One-electron integrals are listed below
            // <0|H|0> = -1.252477495
            // <1|H|1> = -0.475934275

            // Two-electron integrals are listed below
            // <00|H|00> = 0.674493166
            // <01|H|01> = 0.181287518
            // <01|H|10> = 0.663472101
            // <11|H|11> = 0.697398010
            // Note that orbitals are assumed to be real. Moreover, indistinguishability
            // of electrons means that the following integrals are equal.
            //   <PQ|H|RS> = <PR|H|QS> = <SQ|H|RP> = <SR|H|QP>
            // = <QP|H|SR> = <RP|H|SQ> = <QS|H|PR> = <RS|H|PQ>
            // Thus it suffices to specify just any one of these terms from each symmetry
            // group.

            // These orbital integrals are represented using the OrbitalIntegral
            // data structure.
            var orbitalIntegrals = new OrbitalIntegral[]
            {
                new OrbitalIntegral(new[] { 0,0 }, -1.252477495),
                new OrbitalIntegral(new[] { 1,1 }, -0.475934275),
                new OrbitalIntegral(new[] { 0,0,0,0 }, 0.674493166),
                new OrbitalIntegral(new[] { 0,1,0,1 }, 0.181287518),
                new OrbitalIntegral(new[] { 0,1,1,0 }, 0.663472101),
                new OrbitalIntegral(new[] { 1,1,1,1 }, 0.697398010),
                // Add the identity term
                new OrbitalIntegral(new int[] { }, energyOffset)
            };

            // We initialize a fermion Hamiltonian data structure and add terms to it
            var fermionHamiltonian = new OrbitalIntegralHamiltonian(orbitalIntegrals).ToFermionHamiltonian();

            // These orbital integral terms are automatically expanded into
            // spin-orbitals. We may print the Hamiltonian to see verify what it contains.
            Console.WriteLine("----- Print Hamiltonian");
            Console.Write(fermionHamiltonian);
            Console.WriteLine("----- End Print Hamiltonian \n");

            // We also need to create an input quantum state to this Hamiltonian.
            // Let us use the Hartree–Fock state.
            var fermionWavefunction = fermionHamiltonian.CreateHartreeFockState(nElectrons);
            #endregion

            #region Jordan–Wigner representation 
            // The Jordan–Wigner encoding converts the fermion Hamiltonian, 
            // expressed in terms of Fermionic operators, to a qubit Hamiltonian,
            // expressed in terms of Pauli matrices. This is an essential step
            // for simulating our constructed Hamiltonians on a qubit quantum
            // computer.
            Console.WriteLine("----- Creating Jordan–Wigner encoding");
            var jordanWignerEncoding = fermionHamiltonian.ToPauliHamiltonian(Paulis.QubitEncoding.JordanWigner);
            Console.WriteLine("----- End Creating Jordan–Wigner encoding \n");

            // Print the Jordan–Wigner encoded Hamiltonian to see verify what it contains.
            Console.WriteLine("----- Print Hamiltonian");
            Console.Write(jordanWignerEncoding);
            Console.WriteLine("----- End Print Hamiltonian \n");
            #endregion

            #region Performing the simulation 
            // We are now ready to run a quantum simulation of molecular Hydrogen.
            // We will use this to obtain an estimate of its ground state energy.

            // Here, we make an instance of the simulator used to run our Q# code.
            using (var qsim = new QuantumSimulator())
            {

                // This Jordan–Wigner data structure also contains a representation 
                // of the Hamiltonian and wavefunction made for consumption by the Q# algorithms.
                var qSharpHamiltonianData = jordanWignerEncoding.ToQSharpFormat();
                var qSharpWavefunctionData = fermionWavefunction.ToQSharpFormat();
                var qSharpData = QSharpFormat.Convert.ToQSharpFormat(qSharpHamiltonianData, qSharpWavefunctionData);

                // We specify the bits of precision desired in the phase estimation 
                // algorithm
                var bits = 7;

                // We specify the step-size of the simulated time-evolution
                var trotterStep = 0.4;

                // Choose the Trotter integrator order
                Int64 trotterOrder = 1;

                // As the quantum algorithm is probabilistic, let us run a few trials.

                // This may be compared to true value of
                Console.WriteLine("Exact molecular Hydrogen ground state energy: -1.137260278.\n");
                Console.WriteLine("----- Performing quantum energy estimation by Trotter simulation algorithm");
                for (int i = 0; i < 5; i++)
                {
                    // EstimateEnergyByTrotterization
                    // Name should make clear that it does it by trotterized
                    var (phaseEst, energyEst) = GetEnergyByTrotterization.Run(qsim, qSharpData, bits, trotterStep, trotterOrder).Result;

                    Console.WriteLine($"Rep #{i+1}/5: Energy estimate: {energyEst}; Phase estimate: {phaseEst}");
                }
                Console.WriteLine("----- End Performing quantum energy estimation by Trotter simulation algorithm\n");

                Console.WriteLine("----- Performing quantum energy estimation by Qubitization simulation algorithm");
                for (int i = 0; i < 1; i++)
                {
                    // EstimateEnergyByTrotterization
                    // Name should make clear that it does it by trotterized
                    var (phaseEst, energyEst) = GetEnergyByQubitization.Run(qsim, qSharpData, bits).Result;

                    Console.WriteLine($"Rep #{i+1}/1: Energy estimate: {energyEst}; Phase estimate: {phaseEst}");
                }
                Console.WriteLine("----- End Performing quantum energy estimation by Qubitization simulation algorithm\n");
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
