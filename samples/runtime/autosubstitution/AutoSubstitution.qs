// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Project {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Targeting;

    operation ClassicalSWAP(a : Qubit, b : Qubit) : Unit is Adj + Ctl {
        Message("Classical version");
        CNOT(a, b);
        CNOT(b, a);
        CNOT(a, b);
    }

    // This attribute indicates that when running this Q# program with
    // ToffoliSimulator, the operation `ClassicalSWAP` is executed instead.
    @SubstitutableOnTarget("Project.ClassicalSWAP", "ToffoliSimulator")
    operation ApplySingleDirectionSWAP(a : Qubit, b : Qubit) : Unit is Adj + Ctl {
        // Note: In version 0.18.2106148911 we must explicitly reference the
        // operation; otherwise, the compiler removes the operation from the
        // compilation unit before the auto-substitution rewrite step is executed.
        let _ = ClassicalSWAP;

        Message("Quantum version");

        // Implements a SWAP operation in which all CNOT operations have the
        // same control and target qubits.
        within {
            CNOT(a, b);
            H(a);
            H(b);
        } apply {
            CNOT(a, b);
        }
    }

    @EntryPoint()
    operation RunProgram() : Unit {
        use a = Qubit();
        use b = Qubit();

        ApplySingleDirectionSWAP(a, b);
    }
}
