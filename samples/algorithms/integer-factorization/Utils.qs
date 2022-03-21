// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.IntegerFactorization {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    
    operation ApplyXorInPlaceL(value : BigInt, target : LittleEndian) : Unit is Adj+Ctl {
        let bits = BigIntAsBoolArray(value);
        let bitsPadded = Length(bits) > Length(target!) ? bits[...Length(target!) - 1] | bits;
        ApplyPauliFromBitString(PauliX, true, bitsPadded, (target!)[...Length(bitsPadded) - 1]);
    }

    internal function NTrailingZeroes(number : BigInt) : Int {
        mutable nZeroes = 0;
        mutable copy = number;
        while (copy % 2L == 0L) {
            set nZeroes += 1;
            set copy /= 2L;
        }
        return nZeroes;
    }

    internal function BigIntAsBoolArraySized(value : BigInt, numBits : Int) : Bool[] {
        let values = BigIntAsBoolArray(value);
        let n = Length(values);

        return n >= numBits ? values[...numBits - 1] | Padded(-numBits, false, values);
    }

    /// # Summary
    /// An implementation for `CNOT` that when controlled using a single control uses
    /// a helper qubit and uses `ApplyAnd` to reduce the T-count to 4 instead of 7.
    internal operation ApplyLowTCNOT(a : Qubit, b : Qubit) : Unit is Adj+Ctl {
        body (...) {
            CNOT(a, b);
        }

        adjoint self;

        controlled (ctls, ...) {
            // In this application this operation is used in a way that
            // it is controlled by at most one qubit.
            Fact(Length(ctls) <= 1, "At most one control line allowed");

            if IsEmpty(ctls) {
                CNOT(a, b);
            } else {
                use q = Qubit();
                within {
                    ApplyAnd(Head(ctls), a, q);
                } apply {
                    CNOT(q, b);
                }
            }
        }

        adjoint controlled self;
    }
}
