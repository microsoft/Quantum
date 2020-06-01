// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;

    // This operation computes the majority of input qubits `a`, `b`, and `c`
    // onto the output qubit `f`.  If `f` start out in state |0⟩, it is
    // being flipped to |1⟩, if and only if at least two of the three input qubits
    // are state |1⟩.
    operation ApplyMajority(a : Qubit, b : Qubit, c : Qubit, f : Qubit) : Unit {
        // We expect that the target qubit `f` is in state 0.
        AssertQubit(Zero, f);

        within {
            CNOT(b, a);
            CNOT(b, c);
        } apply {
            ApplyAnd(a, c, f);
            CNOT(b, f);
        }
    }

    // The entry point applies the ApplyMajority operation to three qubits that
    // are initialized based on the Boolean input arguments.  It returns the
    // evaluation of the function by measuring the qubit that holds the function
    // output.
    @EntryPoint()
    operation RunMajority(a : Bool, b : Bool, c : Bool) : Bool {
        using ((qa, qb, qc, f) = (Qubit(), Qubit(), Qubit(), Qubit())) {
            within {   
                ApplyPauliFromBitString(PauliX, true, [a, b, c], [qa, qb, qc]);
            } apply {
                ApplyMajority(qa, qb, qc, f);
            }
            return IsResultOne(MResetZ(f));
        }
    }
}
