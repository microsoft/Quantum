// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.Measurement {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;

    /// # Summary
    /// Samples a quantum random number generator (QRNG), returning a single
    /// random bit.
    operation SampleQrng() : Result {
        // The following using block asks the target machine for a fresh qubit,
        // which starts in the |0⟩ state by convention.
        using (qubit = Qubit()) {
            // We use the H operation (short for Hadamard) to prepare our qubit
            // in a superposition of the |0⟩ and |1⟩ states.
            H(qubit);

            // We can now assert that, if we were to measure our qubit, we'd get
            // a Zero outcome with 50% probability.
            // This assertion works fine in a simulator, and is safely skipped
            // if the target machine doesn't support it.
            AssertProb([PauliZ], [qubit], Zero, 0.5, "Error: Outcomes of the measurement must be equally likely", 1E-05);

            // If the assertion above passes or is skipped, we can go on and
            // measure our qubit to get back a classical bit.
            let result = M(qubit);

            // If we got a One back for our classical bit, we know that our
            // qubit is in the |1⟩ state; we can reset it for deallocation
            // by using a bit-flip instruction, represented in Q# as the X
            // operation.
            //
            // Note that this is how the MResetZ operation works!
            if (result == One) {
                X(qubit);
            }

            // Finally, we return the result of the measurement.
            return result;
        }
    }

    /// # Summary
    /// Prepares two qubits in an equal superposition, measures each qubit,
    /// and then returns the results.
    operation MeasureTwoQubits() : (Result, Result) {
        // The following using block allocates a pair of fresh qubits, which
        // start off in the |00〉 state by convention.
        using ((left, right) = (Qubit(), Qubit())) {
            // We can use the H operation again to prepare an equal superposition
            // of |00⟩, |01⟩, |10⟩, and |11⟩.
            ApplyToEach(H, [left, right]);

            // We now assert that the probability for the events of finding the
            // first qubit in the |0〉 state is 50%. Note that this assertion
            // does not actually apply the measurement operation itself, i.e., it
            // has no side effect on the state of the qubits.
            AssertProb([PauliZ], [left], Zero, 0.5, "Error: Outcomes of the measurement must be equally likely", 1E-05);

            // Similarly, we can use AssertProb to check that the second qubit
            // also gives us a Zero outcome with 50% probability.
            AssertProb([PauliZ], [right], Zero, 0.5, "Error: Outcomes of the measurement must be equally likely", 1E-05);

            // Now, we measure each qubit in Z-basis and immediately reset the qubits
            // to zero, using the standard library operation MResetZ.
            return (MResetZ(left), MResetZ(right));
        }
    }

    /// # Summary
    /// Prepares two qubits in an entangled state, measures each, and then
    /// returns the results.
    operation MeasureInBellBasis() : (Result, Result) {
        // The following using block allocates a pair of fresh qubits, which
        // start off in the |00〉 state by convention.
        using ((left, right) = (Qubit(), Qubit())) {
            // By applying the Hadamard and controlled-NOT (CNOT) operations,
            // we can prepare our qubits in an equal superposition of |00⟩ and
            // |11⟩. This state is sometimes known as a Bell state.
            H(left);
            CNOT(left, right);

            // The following two assertions ascertain that the created state is indeed
            // invariant under both, the XX and the ZZ operations, i.e., it projects
            // into the +1 eigenstate of these two Pauli operators.
            Assert([PauliZ, PauliZ], [left, right], Zero, "Error: Bell state must be eigenstate of ZZ");
            Assert([PauliX, PauliX], [left, right], Zero, "Error: Bell state must be eigenstate of XX");
            AssertProb([PauliZ, PauliZ], [left, right], One, 0.0, "Error: 01 or 10 should never occur as an outcome", 1E-05);

            // Finally, we measure each qubit in the Z-basis and return the
            // results.
            return (MResetZ(left), MResetZ(right));
        }
    }

    /// # Summary
    /// Runs the various operations defined in this sample. This operation
    /// can be used as an entry point from a classical host program.
    operation RunQuantumMain() : Unit {
        
        Message("## SampleQrng() ##");
        mutable count = 0;

        for (idx in 0..99) {
            set count += SampleQrng() == One ? 1 | 0;
        }

        Message($"Est. probability of Zero given H|0⟩: {count} / 100");

        Message("## MeasureTwoQubits() ##");
        for (idx in 0..7) {
            let (left, right) = MeasureTwoQubits();
            Message($"Measured HH|00⟩ and observed ({left}, {right}).");
        }

        Message("## MeasureInBellBasis() ##");
        for (idx in 0..7) {
            let (left, right) = MeasureInBellBasis();
            Message($"Measured CNOT · H |00⟩ and observed ({left}, {right})");
        }

    }

}


