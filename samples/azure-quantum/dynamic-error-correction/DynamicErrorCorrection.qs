namespace Tests.Common {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;

    @EntryPoint()
    operation DynamicBitFlipCode() : (Bool, Int) {
        // Use two qubit registers, one for representing a logical qubit and another one as auxiliary to detect the
        // error syndrome.
        use logicalRegister = Qubit[3];
        use auxiliaryRegister = Qubit[2];

        // Initialize the first qubit in the register to a |-〉 state.
        H(logicalRegister[0]);
        Z(logicalRegister[0]);

        // Apply several unitary operations to the encoded qubits performing error correction between each application.
        mutable corrections = 0;
        within {
            // The 3 qubit register is used to represent a single logical qubit using an error correcting repetition code.
            Encode(logicalRegister);
        }
        apply {
            let iterations = 5;
            for _ in 1 .. iterations {
                // Apply a sequence of rotations to the logical register that effectively perform an identity operation.
                ApplyRotationalIdentity(logicalRegister);

                // Measure the error syndrome, perform error correction based on it if needed, and increase the 
                // corrections counter if a correction was made.
                let (parity01, parity12) = MeasureSyndrome(logicalRegister, auxiliaryRegister);
                let correctedError = CorrectError(logicalRegister, parity01, parity12);
                if (correctedError) {
                    set corrections += 1;
                }
            }
        }

        // Transform the qubit to the |1〉 state and measure it in the computational basis.
        H(logicalRegister[0]);
        let result = MResetZ(logicalRegister[0]) == One;
        ResetAll(logicalRegister);

        // The output of the program is a boolean-integer tuple where the boolean represents whether the qubit
        // measurement result was the expected one and the integer represents the number of times error correction was
        // performed.
        return (result, corrections);
    }

    operation ApplyRotationalIdentity(register : Qubit[]) : Unit is Adj
    {
        // The Rx operation has a period of $2\pi$, which after eight $\pi/2$ rotations, effectively leaves the qubit in
        // the same state if no noise is present.
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
        // Measure the error syndrome by checking the parities between qubits 0 and 1, and between qubits 1 and 2.
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
