// Copyright (c) Microsoft Corporation. All rights reserved.
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

    @SubstitutableOnTarget("Project.ClassicalSWAP", "ToffoliSimulator")
    operation ApplySingleDirectionSWAP(a : Qubit, b : Qubit) : Unit is Adj + Ctl {
        Message("Quantum version");
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

        let _ = ClassicalSWAP;
        ApplySingleDirectionSWAP(a, b);
    }
}
