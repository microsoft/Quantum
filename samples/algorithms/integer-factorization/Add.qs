// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.IntegerFactorization {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;

    /// # Summary
    /// Performs in-place addition of two quantum registers.
    ///
    /// # Description
    /// Given two inputs $|x\rangle$ and $|y\rangle$,
    /// computes $|x + y\rangle$ into $|y\rangle$, if `y`'s length
    /// is one larger than `x`'s length.  If both lengths are
    /// the same, $n$, then it computes $|(x + y) \bmod 2^n\rangle$
    /// into $|y\rangle$.
    ///
    /// # Input
    /// ## x
    /// Quantum register of first summand.
    /// ## y
    /// Quantum register of second summand and target; must be either
    /// the same length as `x` or one larger.
    operation Add(x : LittleEndian, y : LittleEndian) : Unit is Adj+Ctl {
        let n = Length(x!);
        Fact(n > 0, "Bitwidth must be at least 1");

        if Length(y!) == n + 1 {
            AddWithCarryOut(false, x, y);
        } else {
            AddWithoutCarryOut(false, false, x, y);
        }
    }

    /// # Summary
    /// Performs in-place addition of two quantum registers with a carry input.
    ///
    /// # Description
    /// Given two inputs $|x\rangle$ and $|y\rangle$, and a carry input $|c\rangle$
    /// computes $|x + y + c\rangle$ into $|y\rangle$, if `y`'s length
    /// is one larger than `x`'s length.  If both lengths are
    /// the same, $n$, then it computes $|(x + y + c) \bmod 2^n\rangle$
    /// into $|y\rangle$.
    ///
    /// # Input
    /// ## x
    /// Quantum register of first summand.
    /// ## y
    /// Quantum register of second summand and target; must be either
    /// the same length as `x` or one larger.
    /// ## carryIn
    /// Carry input $|c\rangle$.
    operation AddWithCarryIn(x : LittleEndian, y : LittleEndian, carryIn : Qubit) : Unit is Adj+Ctl {
        let n = Length(x!);
        Fact(n > 0, "Bitwidth must be at least 1");

        if Length(y!) == n + 1 {
            AddWithCarryInAndOut(x, y, carryIn);
        } else {
            EqualityFactI(Length(y!), n, "Bitwidth of x and y must equal");

            if n == 1 {
                Sum(carryIn, Head(x!), Head(y!));
            } else {
                use carry = Qubit();
                Carry(carryIn, Head(x!), Head(y!), carry);
                AddWithCarryIn(LittleEndian(Rest(x!)), LittleEndian(Rest(y!)), carry);
                Uncarry(carryIn, Head(x!), Head(y!), carry);
            }
        }
    }

    /// # Summary
    /// Performs in-place addition of a constant into a quantum register.
    ///
    /// # Description
    /// Given a non-empty quantum register $|y\rangle$ of length $n+1$ and a positive
    /// constant $c < 2^n$, computes $|y + c\rangle$ into $|y\rangle$.
    ///
    /// # Input
    /// ## c
    /// Constant number to add to $|y\rangle$.
    /// ## y
    /// Quantum register of second summand and target; must not be empty.
    operation AddConstant(c : BigInt, y : LittleEndian) : Unit is Adj+Ctl {
        let n = Length(y!);
        Fact(n > 0, "Bitwidth must be at least 1");

        Fact(c >= 0L, "constant must not be negative");
        Fact(c < PowL(2L, n), $"constant must be smaller than {PowL(2L, n)}");

        if c != 0L {
            let j = TrailingZeroes(c);
            use x = Qubit[n - j];
            let xreg = LittleEndian(x);
            within {
                ApplyXorInPlaceL(c >>> j, xreg);
            } apply {
                AddWithoutCarryOut(false, true, xreg, LittleEndian((y!)[j...]));
            }
        }
    }

    internal operation AddWithCarryInAndOut(x : LittleEndian, y : LittleEndian, carryIn : Qubit) : Unit is Adj+Ctl {
        body (...) {
            let n = Length(x!);
            Fact(n > 0, "Bitwidth must be at least 1");
            EqualityFactI(Length(y!), n + 1, "Bitwidth of y must be 1 more than x");

            let carryOut = Tail(y!);
            AssertAllZero([carryOut]);

            if n == 1 {
                Carry(carryIn, Head(x!), Head(y!), carryOut);
                CNOT(carryIn, Head(x!));
                CNOT(Head(x!), Head(y!));
            } else {
                use carry = Qubit();
                Carry(carryIn, Head(x!), Head(y!), carry);
                AddWithCarryInAndOut(LittleEndian(Rest(x!)), LittleEndian(Rest(y!)), carry);
                Uncarry(carryIn, Head(x!), Head(y!), carry);
            }
        }

        adjoint auto;

        controlled (ctls, ...) {
            let n = Length(x!);
            Fact(n > 0, "Bitwidth must be at least 1");
            EqualityFactI(Length(y!), n + 1, "Bitwidth of y must be 1 more than x");
            EqualityFactI(Length(ctls), 1, "Number of control lines must be 1");

            let carryOut = Tail(y!);
            AssertAllZero([carryOut]);

            if n == 1 {
                use carry = Qubit();
                Carry(carryIn, Head(x!), Head(y!), carry);
                ApplyAnd(ctls[0], carry, carryOut);
                Controlled Uncarry(ctls, (carryIn, Head(x!), Head(y!), carry));
            } else {
                use carry = Qubit();
                Carry(carryIn, Head(x!), Head(y!), carry);
                Controlled AddWithCarryInAndOut(ctls, (LittleEndian(Rest(x!)), LittleEndian(Rest(y!)), carry));
                Controlled Uncarry(ctls, (carryIn, Head(x!), Head(y!), carry));
            }
        }
    }

    internal operation AddWithoutCarryOut(useInSubtract : Bool, xIsOddConstant : Bool, x : LittleEndian, y : LittleEndian) : Unit is Adj+Ctl {
        let n = Length(x!);
        Fact(n > 0, "Bitwidth must be at least 1");
        EqualityFactI(Length(y!), n, "Bitwidth of x and y must equal, or y is one larger than x");

        if n == 1 {
            HalfSum(useInSubtract, xIsOddConstant, Head(x!), Head(y!));
        } else {
            use carry = Qubit();
            HalfCarry(useInSubtract, xIsOddConstant, Head(x!), Head(y!), carry);
            AddWithCarryIn(LittleEndian(Rest(x!)), LittleEndian(Rest(y!)), carry);
            HalfUncarry(useInSubtract, xIsOddConstant, Head(x!), Head(y!), carry);
        }
    }

    internal operation AddWithCarryOut(useInSubtract : Bool, x : LittleEndian, y : LittleEndian) : Unit is Adj+Ctl {
        body (...) {
            let n = Length(x!);
            Fact(n > 0, "Bitwidth must be at least 1");
            EqualityFactI(Length(y!), n + 1, "Bitwidth of y must be 1 more than x");

            let carryOut = Tail(y!);
            AssertAllZero([carryOut]);

            if n == 1 {
                HalfCarry(useInSubtract, false, Head(x!), Head(y!), carryOut);
                ApplyIfCA(useInSubtract, X, Head(x!));
                CNOT(Head(x!), Head(y!));
            } else {
                use carry = Qubit();
                HalfCarry(useInSubtract, false, Head(x!), Head(y!), carry);
                AddWithCarryInAndOut(LittleEndian(Rest(x!)), LittleEndian(Rest(y!)), carry);
                HalfUncarry(useInSubtract, false, Head(x!), Head(y!), carry);
            }
        }

        adjoint auto;

        controlled (ctls, ...) {
            let n = Length(x!);
            Fact(n > 0, "Bitwidth must be at least 1");
            EqualityFactI(Length(y!), n + 1, "Bitwidth of y must be 1 more than x");
            EqualityFactI(Length(ctls), 1, "Number of control lines must be 1");

            let carryOut = Tail(y!);
            AssertAllZero([carryOut]);

            if n == 1 {
                use carry = Qubit();
                HalfCarry(useInSubtract, false, Head(x!), Head(y!), carry);
                ApplyAnd(ctls[0], carry, carryOut);
                Controlled HalfUncarry(ctls, (useInSubtract, false, Head(x!), Head(y!), carry));
            } else {
                use carry = Qubit();
                HalfCarry(useInSubtract, false, Head(x!), Head(y!), carry);
                Controlled AddWithCarryInAndOut(ctls, (LittleEndian(Rest(x!)), LittleEndian(Rest(y!)), carry));
                Controlled HalfUncarry(ctls, (useInSubtract, false, Head(x!), Head(y!), carry));
            }
        }
    }

    internal operation Carry(carryIn : Qubit, x : Qubit, y : Qubit, carryOut : Qubit) : Unit is Adj+Ctl {
        body (...) {
            Controlled Carry(EmptyArray<Qubit>(), (carryIn, x, y, carryOut));
        }

        adjoint auto;

        controlled (ctls, ...) {
            Fact(Length(ctls) <= 1, "Number of control lines must be at most 1");

            CNOT(carryIn, x);
            CNOT(carryIn, y);
            ApplyAnd(x, y, carryOut);
            CNOT(carryIn, carryOut);
        }

        controlled adjoint auto;
    }

    /// # Summary
    /// Computes carry operation with constant carry input
    ///
    /// # Description
    /// Computes |qxy0〉↦ |q(x⊕q)(y⊕q)〈qxy〉〉 for a constant q.
    ///
    /// Further, it can be specified that x is assumed to be 1.
    ///
    /// # Input
    /// ## carryIn
    /// value for carry in
    /// ## xIsOddConstant
    /// assume that x is One
    /// ## x
    /// first summand
    /// ## y
    /// second summand
    /// ## carryOut
    /// carry out qubit
    internal operation HalfCarry(carryIn : Bool, xIsOddConstant : Bool, x : Qubit, y : Qubit, carryOut : Qubit) : Unit is Adj+Ctl {
        body (...) {
            Controlled HalfCarry(EmptyArray<Qubit>(), (carryIn, xIsOddConstant, x, y, carryOut));
        }

        adjoint auto;

        controlled (ctls, ...) {
            Fact(Length(ctls) <= 1, "Number of control lines must be at most 1");

            ApplyIfA(carryIn, ApplyToEachA(X, _), [x, y]);
            if xIsOddConstant {
              AssertAllZero([carryOut]);
                CNOT(y, carryOut);
            } else {
                ApplyAnd(x, y, carryOut);
            }
            ApplyIfA(carryIn, X, carryOut);
        }

        controlled adjoint auto;
    }

    internal operation Uncarry(carryIn : Qubit, x : Qubit, y : Qubit, carryOut : Qubit) : Unit is Adj+Ctl {
        body (...) {
            CNOT(carryIn, carryOut);
            Adjoint ApplyAnd(x, y, carryOut);
            CNOT(carryIn, x);
            CNOT(x, y);
        }

        adjoint auto;

        controlled (ctls, ...) {
            EqualityFactI(Length(ctls), 1, "Number of control lines must be 1");

            CNOT(carryIn, carryOut);
            Adjoint ApplyAnd(x, y, carryOut);

            within {
                ApplyAnd(ctls[0], x, carryOut);
            } apply {
                CNOT(carryOut, y);
            }
            CNOT(carryIn, x);
            CNOT(carryIn, y);
        }

        controlled adjoint auto;
    }

    internal operation HalfUncarry(carryIn: Bool, xIsOddConstant : Bool, x : Qubit, y : Qubit, carryOut : Qubit) : Unit is Adj {
        body (...) {
            ApplyIfA(carryIn, X, carryOut);
            if xIsOddConstant {
                CNOT(y, carryOut);
                X(y);
            } else {
                Adjoint ApplyAnd(x, y, carryOut);
                CNOT(x, y);
            }
            ApplyIfA(carryIn, ApplyToEachA(X, _), [x, y]);
        }

        adjoint auto;

        controlled (ctls, ...) {
            EqualityFactI(Length(ctls), 1, "Number of control lines must be 1");

            ApplyIfA(carryIn, X, carryOut);
            if xIsOddConstant {
                CNOT(y, carryOut);
                CNOT(ctls[0], y);
            } else {
                Adjoint ApplyAnd(x, y, carryOut);
                //AssertAllZero([carryOut]);

                within {
                    ApplyAnd(ctls[0], x, carryOut);
                } apply {
                    CNOT(carryOut, y);
                }
            }
            ApplyIfA(carryIn, ApplyToEachA(X, _), [x, y]);
        }

        controlled adjoint auto;
    }

    internal operation Sum(carryIn : Qubit, x : Qubit, y : Qubit) : Unit is Adj+Ctl {
        body (...) {
            CNOT(carryIn, y);
            CNOT(x, y);
        }

        adjoint self;

        controlled (ctls, ...) {
            EqualityFactI(Length(ctls), 1, "Number of control lines must be 1");

            use q = Qubit();
            within {
                CNOT(carryIn, x);
                ApplyAnd(ctls[0], x, q);
            } apply {
                CNOT(q, y);
            }
        }

        controlled adjoint self;
    }

    internal operation HalfSum(carryIn : Bool, xIsOddConstant : Bool, x : Qubit, y : Qubit) : Unit is Adj+Ctl {
        body (...) {
            ApplyIfA(carryIn, X, y);
            if xIsOddConstant {
                X(y);
            } else {
                CNOT(x, y);
            }
        }

        adjoint self;

        controlled (ctls, ...) {
            EqualityFactI(Length(ctls), 1, "Number of control lines must be 1");

            if xIsOddConstant {
                if not carryIn {
                    CNOT(ctls[0], y);
                }
            } else {
                use q = Qubit();
                within {
                    ApplyIfA(carryIn, X, x);
                    ApplyAnd(ctls[0], x, q);
                } apply {
                    CNOT(q, y);
                }
            }
        }

        controlled adjoint self;
    }
}
