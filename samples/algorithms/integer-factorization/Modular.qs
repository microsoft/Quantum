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

    /// # Summary
    /// Performs modular in-place addition of a classical constant into a
    /// quantum register.
    ///
    /// # Description
    /// Given the classical constants `c` and `modulus`, and an input
    /// quantum register (as LittleEndian) $|y\rangle$, this operation
    /// computes `(x+c) % modulus` into $|y\rangle$.
    ///
    /// # Input
    /// ## modulus
    /// Modulus to use for modular addition
    /// ## c
    /// Constant to add to $|y\rangle$
    /// ## y
    /// Quantum register of target
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

    /// # Summary
    /// Performs modular in-place multiplication by a classical constant.
    ///
    /// # Description
    /// Given the classical constants `c` and `modulus`, and an input
    /// quantum register (as LittleEndian) $|y\rangle$, this operation
    /// computes `(c*x) % modulus` into $|y\rangle$.
    ///
    /// # Input
    /// ## modulus
    /// Modulus to use for modular multiplication
    /// ## c
    /// Constant by which to multiply $|y\rangle$
    /// ## y
    /// Quantum register of target
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
