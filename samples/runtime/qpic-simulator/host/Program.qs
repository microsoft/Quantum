// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Measurement;

    internal operation Toffoli(a : Qubit, b : Qubit, c : Qubit) : Unit {
        H(c);
        ApplyToEach(T, [a, b, c]);
        CNOT(b, a);
        CNOT(c, b);
        CNOT(a, c);
        Adjoint T(b);
        CNOT(a, b);
        Adjoint T(a);
        Adjoint T(b);
        T(c);
        CNOT(c, b);
        CNOT(a, c);
        CNOT(b, a);
        H(c);
    }

    internal operation TInject(a : Qubit, b : Qubit) : Unit {
        H(a);
        T(a);
        Barrier();
        CNOT(b, a);
        if (M(a) == One) {
            S(b);
            X(a);
        }
    }

    @Test("Microsoft.Quantum.Samples.QpicSimulator")
    operation PrintToffoli() : Unit {
        within { SavePicture("toffoli.qpic"); }
        apply {
            using ((a, b, c) = (Qubit(), Qubit(), Qubit())) {
                Toffoli(a, b, c);
            }
        }
    }

    @Test("Microsoft.Quantum.Samples.QpicSimulator")
    operation PrintTInject() : Unit {
        within { SavePicture("t-injection.qpic"); }
        apply {
            using ((a, b) = (Qubit(), Qubit())) {
                TInject(a, b);
            }
        }
    }

    @Test("Microsoft.Quantum.Samples.QpicSimulator")
    operation PrintIfThenElse() : Unit {
        within { SavePicture("if-then-else.qpic"); }
        apply {
            using ((a, b) = (Qubit(), Qubit())) {
                H(a);
                let result = M(a);
                if (result == One) {
                    X(b);
                } else {
                    Z(b);
                }
            }
        }
    }
}
