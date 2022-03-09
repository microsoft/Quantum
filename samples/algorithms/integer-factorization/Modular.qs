// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.IntegerFactorization {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;

    operation ModularAddConstant(modulus : BigInt, c : BigInt, y : LittleEndian)
    : Unit is Adj + Ctl {
        body (...) {
            Controlled ModularAddConstant([], (modulus, c, y));
        }
        controlled (ctrls, ...) {
            if Length(ctrls) >= 2 {
                use control = Qubit();
                within {
                    Controlled X(ctrls, control);
                } apply {
                    Controlled ModularAddConstant([control], (modulus, c, y));
                }
            }
            else {
                use carry = Qubit();
                Controlled AddConstant(ctrls, (c, LittleEndian(y! + [carry])));
                Controlled Adjoint AddConstant(ctrls, (modulus, LittleEndian(y! + [carry])));
                Controlled AddConstant([carry], (modulus, y));
                Controlled GreaterThanOrEqualConstant(ctrls, (c, y, carry));
            }
        }
    }

    operation ModularMulByConstant(modulus : BigInt, c : BigInt, y : LittleEndian)
    : Unit is Adj + Ctl {
        use qs = Qubit[Length(y!)];
        for (idx, yq) in Enumerated(y!) {
            let shiftedC = ModL(c <<< idx, modulus);
            Controlled ModularAddConstant([yq], (modulus, shiftedC, LittleEndian(qs)));
        }
        ApplyToEachCA(SWAP, Zipped(y!, qs));
        let invC = InverseModL(c, modulus);
        for (idx, yq) in Enumerated(y!) {
            let shiftedC = ModL(invC <<< idx, modulus);
            Controlled ModularAddConstant([yq], (modulus, modulus - shiftedC, LittleEndian(qs)));
        }
    }
}
