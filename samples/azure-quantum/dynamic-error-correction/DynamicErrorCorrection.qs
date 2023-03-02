namespace Tests.Common {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;

    @EntryPoint()
    operation DynamicBitFlipCode() : (Bool, Int) {
        // Create a register that represents a logical qubit.
        use logicalRegister = Qubit[3];
        use auxiliaryRegister = Qubit[2];

        // Initialize the first qubit in the register to a |-〉 state.
        H(logicalRegister[0]);
        Z(logicalRegister[0]);

        // Apply several unitary operations to the encoded qubits performing error correction between each application.
        mutable corrections = 0;
        within {
            // Encode/Decode logical qubit.
            Encode(logicalRegister);
        }
        apply {
            let iterations = 5;
            for _ in 1 .. iterations {
                // Apply a rotational identity to the logical register.
                ApplyRotationalIdentity(logicalRegister);

                // Perform error correction and increase the counter if a correction was made.
                let (parity01, parity12) = MeasureSyndrome(logicalRegister, auxiliaryRegister);
                let correctedError = CorrectError(logicalRegister, parity01, parity12);
                if (correctedError) {
                    set corrections += 1;
                }
            }
        }

        // Measure the first qubit in each register, return the measurement result and the corrections count.
        H(logicalRegister[0]);
        let result = MResetZ(logicalRegister[0]) == One;
        ResetAll(logicalRegister);
        return (result, corrections);
    }

    operation ApplyRotationalIdentity(register : Qubit[]) : Unit is Adj
    {
        // Rx has a 4 x pi period so this effectively leaves the qubit in the same state at the end if no noise is present.
        let theta = PI() * 0.5;
        for i in 1 .. 8 {
            for qubit in register
            {
                Rx(theta, qubit);
            }
        }
    }

    operation CorrectError(register : Qubit[], parity01 : Result, parity12 : Result) : Bool
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

    operation MeasureSyndrome(logicalRegister : Qubit[], auxiliaryRegister : Qubit[]) : (Result, Result)
    {
        // Verify parity between qubits.
        ResetAll(auxiliaryRegister);
        CNOT(logicalRegister[0], auxiliaryRegister[0]);
        CNOT(logicalRegister[1], auxiliaryRegister[0]);
        CNOT(logicalRegister[1], auxiliaryRegister[1]);
        CNOT(logicalRegister[2], auxiliaryRegister[1]);
        let parity01 = MResetZ(auxiliaryRegister[0]);
        let parity12 = MResetZ(auxiliaryRegister[1]);
        return (parity01, parity12);
    }
}
