// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;


    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Superdense coding
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Superdense coding transfers 2 classical bits by encoding them into 1 qubit,
    // using 1 EPR pair ("2c=1q+1e").

    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// Test run of the protocol. We first create an EPR pair between two
    /// ancilla qubits. Depending on the value of two classical bits then one out of 4
    /// possible Bell states is created by applying a local transformation to just one
    /// half of the EPR pair. Finally, a Bell measurement is applied to
    /// decode the two bits of classical information from the state.
    ///
    /// # References
    /// - [ *Michael A. Nielsen , Isaac L. Chuang*,
    ///     Quantum Computation and Quantum Information ](http://doi.org/10.1017/CBO9780511976667)
    ///
    /// # See Also
    /// - See Section 2.3 of Nielsen & Chuang for detailed discussion of the
    ///   superdense coding
    ///
    /// # Remarks
    /// We encode the bits we are going to transmit in the run of the protocol
    /// in the array of Integers, so this function can be used
    /// with IterateThroughCartesianPower.
    operation RunSuperdenseCoding(bitsAsInt : Int[]) : Unit {
        EqualityFactI(2, Length(bitsAsInt), "Array bitsAsInt must have length 2");

        // Get the bits we are going to transmit.
        let (bit1, bit2) = (bitsAsInt[0] == 0, bitsAsInt[1] == 0);

        // Get a temporary register for the protocol run.
        use qubit1 = Qubit();
        use qubit2 = Qubit();

        // Create an EPR pair shared between A and B.
        CreateEPRPair(qubit1, qubit2);

        // A encodes 2 bits in the first qubit.
        SuperdenseEncode(bit1, bit2, qubit1);

        // "Send" qubit to B and let B decode two bits.
        let (decodedBit1, decodedBit2) = SuperdenseDecode(qubit1, qubit2);

        // Now test if the bits were transferred correctly.
        EqualityFactB(bit1, decodedBit1, "bit1 should be transferred correctly");
        EqualityFactB(bit2, decodedBit2, "bit2 should be transferred correctly");

        // Make sure that we return qubits back in 0 state.
        ResetAll([qubit1, qubit2]);
    }


    /// # Summary
    /// Creates an EPR ( also known as Bell ) pair from 2 qubits initialized
    /// into zero state.
    /// In Dirac notation EPR state is (|00⟩+|11⟩)/√2.
    operation CreateEPRPair(qubit1 : Qubit, qubit2 : Qubit) : Unit {
        // Check that the inputs are as expected.
        AssertMeasurement([PauliZ], [qubit1], Zero, "First qubit is expected to be in a zero state");
        AssertMeasurement([PauliZ], [qubit2], Zero, "Second qubit is expected to be in a zero state");

        // Make an EPR pair.
        H(qubit1);
        CNOT(qubit1, qubit2);

        // Check that we indeed prepared one.
        AssertMeasurement([PauliZ, PauliZ], [qubit1, qubit2], Zero, "EPR state must be +1 eigenstate of ZZ");
        AssertMeasurement([PauliX, PauliX], [qubit1, qubit2], Zero, "EPR state must be +1 eigenstate of XX");
    }


    /// # Summary
    /// Encodes two bits of information in one qubit. The qubit is expected to
    /// be a half of an EPR pair.
    operation SuperdenseEncode(bit1 : Bool, bit2 : Bool, qubit : Qubit) : Unit {
        if (bit1) {
            Z(qubit);
        }

        if (bit2) {
            X(qubit);
        }
    }


    /// # Summary
    /// Decodes two bits of information from a joint state of two qubits.
    operation SuperdenseDecode(qubit1 : Qubit, qubit2 : Qubit) : (Bool, Bool) {

        // If bit1 in the encoding procedure was true we applied Z to
        // the first qubit which anti-commutes with XX, therefore bit1
        // can be read out from XX measurement.
        let bit1 = Measure([PauliX, PauliX], [qubit1, qubit2]) == One;

        // If bit2 in the encoding procedure was true we applied X to
        // the first qubit which anti-commutes with ZZ, therefore bit2
        // can be read out from ZZ measurement.
        let bit2 = Measure([PauliZ, PauliZ], [qubit1, qubit2]) == One;
        return (bit1, bit2);
    }

}


