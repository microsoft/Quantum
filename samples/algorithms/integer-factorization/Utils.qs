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

    internal function TrailingZeroes(number : BigInt) : Int {
        mutable zeroes = 0;
        mutable copy = number;
        while (copy % 2L == 0L) {
            set zeroes += 1;
            set copy /= 2L;
        }
        return zeroes;
    }

    internal function BigIntAsBoolArraySized(value : BigInt, numBits : Int) : Bool[] {
        let values = BigIntAsBoolArray(value);
        let n = Length(values);

        return n >= numBits ? values[...numBits - 1] | Padded(-numBits, false, values);
    }

    internal operation LowTCNOT(a : Qubit, b : Qubit) : Unit is Adj+Ctl {
        body (...) {
            CNOT(a, b);
        }

        adjoint self;

        controlled (ctls, ...) {
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
