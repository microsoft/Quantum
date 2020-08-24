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
    open Microsoft.Quantum.Simulation.QuantumProcessor.Extensions as Extensions;

    /// # Summary
    /// Implements the Toffoli operation (CCNOT) using Clifford+T gates
    ///
    ///
    /// # Reference
    /// This circuit is described in Figure 13 of
    /// [arXiv:1206.0758](https://arxiv.org/pdf/1206.0758.pdf)
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

    /// # Summary
    /// Applies a T operation to `b` using a T state prepared
    /// on `a`
    internal operation InjectT(a : Qubit, b : Qubit) : Unit {
        // prepare T state |T⟩ = TH|0⟩
        H(a);
        T(a);

        // `Barrier` is an intrinsic operation offered by the ⟨q|pic⟩
        // simulator to draw a barrier into the circuit diagram (it
        // has no effect in other simulators)
        Barrier();
        CNOT(b, a);

        // This applies `S` to `b` if and only if measuring `a` in
        // the Z basis returns One.  (Since simulators only capture
        // execution traces, we need to use this construct instead
        // of an if-then-else expression.)
        Extensions.ApplyIfOne(MResetZ(a), (S, b));
    }

    @Test("Microsoft.Quantum.Samples.QpicSimulator")
    operation PrintToffoli() : Unit {
        // The `SavePicture` operation in the `within` block will
        // create a circuit diagram of the operations in the `apply`
        // block in the corresponding file.  It is an intrinsic operation
        // offered by the ⟨q|pic⟩ simulator and has no effect in other
        // simulators.
        within { SavePicture("toffoli.qpic"); }
        apply {
            using ((a, b, c) = (Qubit(), Qubit(), Qubit())) {
                Toffoli(a, b, c);
            }
        }
    }

    @Test("Microsoft.Quantum.Samples.QpicSimulator")
    operation PrintInjectT() : Unit {
        within { SavePicture("t-injection.qpic"); }
        apply {
            using ((a, b) = (Qubit(), Qubit())) {
                InjectT(a, b);
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

                // This applies `Z` to `b` if measuring `a` in the
                // Z basis returns One, and `X` to `b` if the
                // measurement result is Zero.  (Since simulators
                // only capture execution traces, we need to use
                // this construct instead of an if-then-else expression.)
                Extensions.ApplyIfElseR(result, (X, b), (Z, b));
            }
        }
    }
}
