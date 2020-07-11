// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;

    // This operation computes the majority of input qubits `a`, `b`, and `c`
    // onto the output qubit `f`.  If `f` is in state 0, it is 1, if and only if
    // at least two of the input qubits are 1.
    operation ApplyMajority(a : Qubit, b : Qubit, c : Qubit, f : Qubit) : Unit {
        within {
            CNOT(b, a);
            CNOT(b, c);
        } apply {
            CCNOT(a, c, f);
            CNOT(b, f);
        }
    }

    // This applies the Majority operation to three qubits who are initialized
    // based on the Boolean input arguments.
    operation RunMajority(a : Bool, b : Bool, c : Bool) : Bool {
        using ((qa, qb, qc, f) = (Qubit(), Qubit(), Qubit(), Qubit())) {
            within {   
                ApplyPauliFromBitString(PauliX, true, [a, b, c], [qa, qb, qc]);
            } apply {
                ApplyMajority(qa, qb, qc, f);
            }

            // The target qubit `f` is measured and reset afterwards.  The
            // operation returns `true`, if and only if the measurement outcome
            // is One.
            return MResetZ(f) == One;
        }
    }
}
