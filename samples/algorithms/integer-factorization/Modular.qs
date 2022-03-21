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
    /// Performs in-place addition of a constant into a quantum register.
    ///
    /// # Description
    /// Given a non-empty quantum register |𝑦⟩ of length 𝑛+1 and a positive
    /// constant 𝑐 < 2ⁿ, computes |𝑦 + c⟩ into |𝑦⟩.
    ///
    /// # Input
    /// ## c
    /// Constant number to add to |𝑦⟩.
    /// ## y
    /// Quantum register of second summand and target; must not be empty.
    operation AddConstant(c : BigInt, y : LittleEndian) : Unit is Adj + Ctl {
        // We are using this version instead of the library version that is based
        // on Fourier angles to show an advantage of sparse simulation in this sample.

        let n = Length(y!);
        Fact(n > 0, "Bit width must be at least 1");

        Fact(c >= 0L, "constant must not be negative");
        Fact(c < PowL(2L, n), $"constant must be smaller than {PowL(2L, n)}");

        if c != 0L {
            // If c has j trailing zeroes than the j least significant bits
            // of y won't be affected by the addition and can therefore be
            // ignored by applying the addition only to the other qubits and
            // shifting c accordingly.
            let j = NTrailingZeroes(c);
            use x = Qubit[n - j];
            let xReg = LittleEndian(x);
            within {
                ApplyXorInPlaceL(c >>> j, xReg);
            } apply {
                AddI(xReg, LittleEndian((y!)[j...]));
            }
        }
    }

    /// # Summary
    /// Performs modular in-place addition of a classical constant into a
    /// quantum register.
    ///
    /// # Description
    /// Given the classical constants `c` and `modulus`, and an input
    /// quantum register (as LittleEndian) |𝑦⟩, this operation
    /// computes `(x+c) % modulus` into |𝑦⟩.
    ///
    /// # Input
    /// ## modulus
    /// Modulus to use for modular addition
    /// ## c
    /// Constant to add to |𝑦⟩
    /// ## y
    /// Quantum register of target
    operation ModularAddConstant(modulus : BigInt, c : BigInt, y : LittleEndian)
    : Unit is Adj + Ctl {
        body (...) {
            Controlled ModularAddConstant([], (modulus, c, y));
        }
        controlled (ctrls, ...) {
            // We apply a custom strategy to control this operation instead of
            // letting the compiler create the controlled variant for us in which
            // the `Controlled` functor would be distributed over each operation
            // in the body.
            //
            // Here we can use some scratch memory to save ensure that at most one
            // control qubit is used for costly operations such as `AddConstant`
            // and `CompareGreaterThenOrEqualConstant`.
            if Length(ctrls) >= 2 {
                use control = Qubit();
                within {
                    Controlled X(ctrls, control);
                } apply {
                    Controlled ModularAddConstant([control], (modulus, c, y));
                }
            } else {
                use carry = Qubit();
                Controlled AddConstant(ctrls, (c, LittleEndian(y! + [carry])));
                Controlled Adjoint AddConstant(ctrls, (modulus, LittleEndian(y! + [carry])));
                Controlled AddConstant([carry], (modulus, y));
                Controlled CompareGreaterThanOrEqualConstant(ctrls, (c, y, carry));
            }
        }
    }

    /// # Summary
    /// Performs modular in-place multiplication by a classical constant.
    ///
    /// # Description
    /// Given the classical constants `c` and `modulus`, and an input
    /// quantum register (as LittleEndian) |𝑦⟩, this operation
    /// computes `(c*x) % modulus` into |𝑦⟩.
    ///
    /// # Input
    /// ## modulus
    /// Modulus to use for modular multiplication
    /// ## c
    /// Constant by which to multiply |𝑦⟩
    /// ## y
    /// Quantum register of target
    operation ModularMultiplyByConstant(modulus : BigInt, c : BigInt, y : LittleEndian)
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
