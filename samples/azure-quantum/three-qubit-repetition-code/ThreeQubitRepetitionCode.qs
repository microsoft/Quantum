// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;

    @EntryPoint()
    operation ThreeQubitRepetitionCode() : (Bool, Int) {
        // Use two qubit registers, one for encoding and an auxiliary one for syndrome measurements.
        use encodedRegister = Qubit[3];
        use auxiliaryRegister = Qubit[2];

        // Initialize the first qubit in the register to a |-〉 state.
        H(encodedRegister[0]);
        Z(encodedRegister[0]);

        // Apply several unitary operations to the encoded qubits performing bit flip detection and correction between
        // each application.
        mutable bitFlipCount = 0;
        within {
            // The 3 qubit register is used as a repetition code.
            Encode(encodedRegister);
        }
        apply {
            let iterations = 5;
            for _ in 1 .. iterations {
                // Apply a sequence of rotations to the encoded register that effectively perform an identity operation.
                ApplyRotationalIdentity(encodedRegister);

                // Measure the bit flip error syndrome, revert the bit flip if needed, and increase the count if a bit flip occurred.
                let (parity01, parity12) = MeasureBitFlipSyndrome(encodedRegister, auxiliaryRegister);
                let bitFlipReverted = RevertBitFlip(encodedRegister, parity01, parity12);
                if (bitFlipReverted) {
                    set bitFlipCount += 1;
                }
            }
        }

        // Transform the qubit to the |1〉 state and measure it in the computational basis.
        H(encodedRegister[0]);
        let result = MResetZ(encodedRegister[0]) == One;
        ResetAll(encodedRegister);

        // The output of the program is a boolean-integer tuple where the boolean represents whether the qubit
        // measurement result was the expected one and the integer represents the number of times bit flips occurred
        // throughout the program.
        return (result, bitFlipCount);
    }

    operation ApplyRotationalIdentity(register : Qubit[]) : Unit is Adj
    {
        // This operation implements an identity operation using rotations about the x-axis.
        // The Rx operation has a period of $2\pi$ (given that it is not possible to measure the difference between
        // states $|\\psi〉$ and $-|\\psi〉$). Using it to apply 4 $\frac{\pi}{2}$ rotations about the x-axis, effectively
        // leaves the qubit register in its original state.
        let theta = PI() * 0.5;
        for i in 1 .. 4 {
            for qubit in register
            {
                Rx(theta, qubit);
            }
        }
    }

    operation RevertBitFlip(register : Qubit[], parity01 : Result, parity12 : Result) : Bool
    {
        if (parity01 == One and parity12 == Zero) {
            X(register[0]);
        }
        elif (parity01 == One and parity12 == One) {
            X(register[1]);
        }
        elif (parity01 == Zero and parity12 == One) {
            X(register[2]);
        }

        return parity01 == One or parity12 == One;
    }

    operation Encode(register : Qubit[]) : Unit is Adj
    {
        CNOT(register[0], register[1]);
        CNOT(register[0], register[2]);
    }

    operation MeasureBitFlipSyndrome(encodedRegister : Qubit[], auxiliaryRegister : Qubit[]) : (Result, Result)
    {
        // Measure the bit flip syndrome by checking the parities between qubits 0 and 1, and between qubits 1 and 2.
        ResetAll(auxiliaryRegister);
        CNOT(encodedRegister[0], auxiliaryRegister[0]);
        CNOT(encodedRegister[1], auxiliaryRegister[0]);
        CNOT(encodedRegister[1], auxiliaryRegister[1]);
        CNOT(encodedRegister[2], auxiliaryRegister[1]);
        let parity01 = MResetZ(auxiliaryRegister[0]);
        let parity12 = MResetZ(auxiliaryRegister[1]);
        return (parity01, parity12);
    }
}
