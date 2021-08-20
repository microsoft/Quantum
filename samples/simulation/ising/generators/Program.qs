// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Ising {
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation RunGenerators() : Unit {
        // Let us represent an Ising Hamiltonian with uniform single-site X coupling, uniform
        // two-site nearest neighbour ZZ coupling, and open boundary conditions.
        let nSites = 7;

        // Here we choose the coefficients of the coupling terms.
        let hAmplitude = 1.23;
        let jAmplitude = 4.56;

        RunIsingGenerator(nSites, hAmplitude, jAmplitude);
        RunHeisenbergGenerator(nSites, hAmplitude, jAmplitude);
    }

    internal operation RunIsingGenerator(nSites : Int, hAmplitude : Double, jAmplitude : Double) : Unit {
        // For diagnostic purposes, before we proceed to the next step, we'll print out a
        // description of the parameters for the Ising model generator.
        Message(
            "Ising model generators:\n" +
            $"\t{nSites} sites\n" +
            $"\t{hAmplitude} transverse field amplitude\n" +
            $"\t{jAmplitude} coupling amplitude.\n"
        );

        // The number of terms in this Hamiltonian is as follows.
        let nTerms = nSites * 2;

        // Let us print out the terms specified by the Ising model generator system to verify that
        // they match expectations. Let us recall that the Paulis IXYZ are represented by integers
        // 0123.
        for idxHamiltonian in 0 .. nTerms - 1 {
            let generatorIndex = Uniform1DIsingGeneratorIndex(nSites, hAmplitude, jAmplitude, idxHamiltonian);
            let ((idxPauliString, coefficients), idxQubits) = generatorIndex!;

            Message(
                $"idxHamiltonian {idxHamiltonian} " +
                $"has Pauli string {idxPauliString} " +
                $"acting on qubits {idxQubits} " +
                $"with coefficient {coefficients[0]}."
            );
        }
    }

    internal operation RunHeisenbergGenerator(nSites : Int, hAmplitude : Double, jAmplitude : Double) : Unit {
        // For diagnostic purposes, before we proceed to the next step, we'll print out a
        // description of the parameters for the Heisenberg model generator.
        Message(
            "\nHeisenberg model generators:\n" +
            $"\t{nSites} sites\n" +
            $"\t{hAmplitude} transverse field amplitude\n" +
            $"\t{jAmplitude} coupling amplitude.\n"
        );

        // The number of terms in this Hamiltonian is as follows.
        let nTerms = nSites * 4;

        // Let us print out the terms specified by the Heisenberg Model generator system to verify
        // that they match expectations.
        for idxHamiltonian in 0 .. nTerms - 1 {
            let generatorIndex = HeisenbergXXZGeneratorIndex(nSites, hAmplitude, jAmplitude, idxHamiltonian);
            let ((idxPauliString, coefficients), idxQubits) = generatorIndex!;

            Message(
                $"idxHamiltonian {idxHamiltonian} " +
                $"has Pauli string {idxPauliString} " +
                $"acting on qubits {idxQubits} " +
                $"with coefficient {coefficients[0]}."
            );
        }
    }
}
