// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Samples a random number by measuring a register of qubits in superposition.
    @EntryPoint() // The EntryPoint attribute is used to mark that this operation is where a quantum program will start running.
    operation SampleRandomNumber() : Result[] {

        // We prepare a register of qubits in a uniform
        // superposition state, such that when we measure,
        // all bitstrings occur with equal probability.
        let nQubits = 5;
        use register = Qubit[nQubits];
        
        // Set qubits in superposition.
        for qubit in register {
            H(qubit);
        }

        // Measure all qubits and return.
        return MeasureEachZ (register);
    }
}
