// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Samples a random number by measuring a register of qubits in parallel.
    ///
    /// # Input
    /// ## nQubits
    /// The number of qubits to measure.
    @EntryPoint() // The EntryPoint attribute is used to mark that this
                  // operation is where your quantum program will start running.
    operation SampleRandomNumber(nQubits : Int) : Result[] {

        // We prepare a register of qubits in a uniform
        // superposition state, such that when we measure,
        // all bitstrings occur with equal probability.
        use register = Qubit[nQubits];

        // Set qubits in superposition.
        ApplyToEachA(H, register);

        // Measure all qubits and return.
        return ForEach(MResetZ, register);

    }
}
