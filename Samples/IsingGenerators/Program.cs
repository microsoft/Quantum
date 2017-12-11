// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

// Intent: Let users construct generators for the Ising Hamiltonian and print them out in c#

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

            // Let us represent an Ising Hamiltonian with uniform single-site X coupling, 
            // uniform two-site nearest neighbour ZZ coupling, and open boundary
            // conditions
            var nSites = 7;
            // The number of terms in this Hamiltonian is as follows.
            var nTerms = nSites * 2;

            // Here we choose the coefficients of these coupling terms.
            var hAmplitude = 1.23;
            var jAmplitude = 4.56;

            // We will do the same for the Heisenberg XXZ Hamiltonian.
            var nTermsXXZ = nSites * 4;

            // For diagnostic purposes, before we proceed to the next step, we'll print
            // out a description of the parameters we just defined.
            Console.WriteLine("Ising model generators:");
            Console.WriteLine($"\t{nSites} sites\n\t{hAmplitude} transverse field amplitude \n\t{jAmplitude} coupling amplitude. \n");

            #endregion

            #region Calling into Q#

            // Let us print out the terms specified by the Ising model generator
            // system to verify that they match expectations.
            // Let us recall that the Paulis IXYZ are represented by integers 0123.
            foreach(var idxHamiltonian in Enumerable.Range(0, nTerms)){
                var task = Ising1DUnpackEvolutionGenerator.Run(qsim, nSites, hAmplitude, jAmplitude, idxHamiltonian);

                var generatorIndex = task.Result;

                var idxPauliString = generatorIndex.Item1.Item1.ToArray();
                var coefficient = generatorIndex.Item1.Item2.ToArray()[0];
                var idxQubits = generatorIndex.Item2.ToArray();
                
                Console.Write($"idxHamiltonian {idxHamiltonian} " +
                    $"has Pauli string [{string.Join(",", idxPauliString.Select(x=>x.ToString()).ToArray())}] " +
                    $"acting on qubits [{string.Join(",", idxQubits.Select(x=>x.ToString()).ToArray())}] " +
                    $"with coefficient {coefficient}. \n");

            }

            Console.WriteLine("\n Heisenberg model generators:");
            Console.WriteLine($"\t{nSites} sites\n\t{hAmplitude} transverse field amplitude \n\t{jAmplitude} coupling amplitude. \n");
            
            // Let us print out the terms specified by the Heisenberg Model generator
            // system to verify that they match expectations.
            foreach (var idxHamiltonian in Enumerable.Range(0, nTermsXXZ))
            {
                var task = HeisenbergXXZUnpackGeneratorSystem.Run(qsim, nSites, hAmplitude, jAmplitude, idxHamiltonian);

                var generatorIndex = task.Result;

                var idxPauliString = generatorIndex.Item1.Item1.ToArray();
                var coefficient = generatorIndex.Item1.Item2.ToArray()[0];
                var idxQubits = generatorIndex.Item2.ToArray();

                Console.Write($"idxHamiltonian {idxHamiltonian} " +
                    $"has Pauli string [{string.Join(",", idxPauliString.Select(x => x.ToString()).ToArray())}] " +
                    $"acting on qubits [{string.Join(",", idxQubits.Select(x => x.ToString()).ToArray())}] " +
                    $"with coefficient {coefficient}. \n");

            }

            Console.ReadLine();
            
            #endregion

        }
    }
}
