// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {

    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Counts the number of times measurements of a prepared GHZ state did not match the expected correlations.
    @EntryPoint() // The EntryPoint attribute is used to mark that this operation is where a quantum program will start running.
    operation CheckGHZ() : Int {
        use q = Qubit[3];
        mutable mismatch = 0;
        for _ in 1..10 {
            // Prepare the GHZ state.
            H(q[0]);
            CNOT(q[0], q[1]);
            CNOT(q[1], q[2]);

            // Measures and resets the 3 qubits
            let (r0, r1, r2) = (MResetZ(q[0]), MResetZ(q[1]), MResetZ(q[2]));

            // Adjusts classical value based on qubit measurement results
            if not (r0 == r1 and r1 == r2) {
                set mismatch += 1;
            }
        }
        return mismatch;
    }
}
