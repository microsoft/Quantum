// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;

    /// # Summary
    /// Computes the base-2 logarithm of a number.
    ///
    /// # Input
    /// ## input
    /// A real number $x$.
    ///
    /// # Output
    /// The base-2 logarithm $y = \log_2(x)$ such that $x = 2^y$.
    function Lg(input: Double) : Double
    {
        // Fully-qualified name is required because Log also appears in Primitives
        return Microsoft.Quantum.Extensions.Math.Log(input) / LogOf2();
    }

    /// # Summary
    /// Given an array of integers, returns the largest element.
    ///
    /// # Input
    /// ## values
    /// An array to take the maximum of.
    ///
    /// # Output
    /// The largest element of `values`.
    function Max(values : Int[]) : Int 
    {
        mutable max = values[0];
        let nTerms = Length(values);
        for(idx in 0..nTerms - 1)
        {
            if (values[idx] > max) {
                set max = values[idx];
            }
        }
        return max;
    }

    /// # Summary
    /// Given an array of integers, returns the smallest element.
    ///
    /// # Input
    /// ## values
    /// An array to take the minimum of.
    ///
    /// # Output
    /// The smallest element of `values`.
    function Min(value : Int[]) : Int 
    {
        mutable min = value[0];
        let nTerms = Length(value);
        for(idx in 0..nTerms - 1)
        {
            if (value[idx] < min) {
                set min = value[idx];
            }
        }
        return min;
    }

    /// # Summary
    /// Computes the modulus between two real numbers.
    ///
    /// # Input
    /// ## value
    /// A real number $x$ to take the modulus of.
    /// ## modulo
    /// A real number to take the modulus of $x$ with respect to.
    /// ## minValue
    /// The smallest value to be returned by this function.
    ///
    /// # Remarks
    /// This function computes the real modulus by wrapping the real
    /// line about the unit circle, then finding the angle on the
    /// unit circle corresponding to the input.
    /// The `minValue` input then effectively specifies where to cut the
    /// unit circle.
    ///
    /// # Example
    /// ```qsharp
    ///     // Returns 3 π / 2.
    ///     let y = RealMod(5.5 * PI(), 2.0 * PI(), 0.0)
    ///     // Returns -1.2, since +3.6 and -1.2 are 4.8 apart on the real line,
    ///     // which is a multiple of 2.4.
    ///     let z = RealMod(3.6, 2.4, -1.2);
    /// ```
    function RealMod(value: Double, modulo: Double, minValue: Double) : Double {
        let fractionalValue = 2.0 * PI() * ((value - minValue) / modulo - 0.5 );
        let cosFracValue = Cos(fractionalValue);
        let sinFracValue = Sin(fractionalValue);
        let moduloValue = 0.5 + ArcTan2(sinFracValue, cosFracValue) / ( 2.0 * PI() );
        let output = moduloValue * modulo + minValue;
        return output;
    }

    // NB: .NET's Math library does not provide hyperbolic arcfunctions.

    /// # Summary
    /// Computes the inverse hyperbolic cosine of a number.
    ///
    /// # Input
    /// ## x
    /// A real number $x$.
    ///
    /// # Output
    /// A real number $y$ such that $x = \cosh(y)$.
    function ArcCosh(x : Double) : Double
    {
        // Fully-qualified name is required because Log also appears in Primitives
        return Microsoft.Quantum.Extensions.Math.Log(x + Sqrt(x * x - 1.0));
    }

    /// # Summary
    /// Computes the inverse hyperbolic secant of a number.
    ///
    /// # Input
    /// ## x
    /// A real number $x$.
    ///
    /// # Output
    /// A real number $y$ such that $x = \operatorname{sinh}(y)$.
    function ArcSinh(x : Double) : Double
    {
        // Fully-qualified name is required because Log also appears in Primitives
        return Microsoft.Quantum.Extensions.Math.Log(x + Sqrt(x * x + 1.0));
    }

    /// # Summary
    /// Computes the inverse hyperbolic tangent of a number.
    ///
    /// # Input
    /// ## x
    /// A real number $x$.
    ///
    /// # Output
    /// A real number $y$ such that $x = \tanh(y)$.
    function ArcTanh(x : Double) : Double
    {
        // Fully-qualified name is required because Log also appears in Primitives
        return Microsoft.Quantum.Extensions.Math.Log((1.0 + x) / (1.0 - x)) * 0.5;
    }

    /// # Summary
    /// Computes canonical residue of `value` modulo `modulus`.
    /// # Input
    /// ## value
    /// The value of which residue is computed
    /// ## modulus
    /// The modulus by which residues are take, must be positive
    /// # Output
    /// Integer r between 0 and `modulus - 1' such that `value - r' is divisible by modulus
    ///
    /// # Remarks
    /// This function behaves the way a mathematician would expect Mod function to behave,
    /// as opposed to how operator `%` is behaving in C# and Q#.
    function Modulus( value : Int , modulus : Int ) : Int
    {
        AssertBoolEqual( modulus > 0, true, "`modulus` must be positive" );
        let r = value % modulus;
        if( r < 0 ) { 
            return r + modulus;
        } else {
            return r;
        }
    }

    /// # Summary 
    /// Let us denote expBase by x, power by p and modulus by N. 
    /// The function returns xᵖ mod N . 
    /// We assume that N,x are positive and power is non-negative.
    /// 
    /// # Remarks 
    /// Takes time proportional to the number of bits in `power`, not the power itself
    function ExpMod( expBase : Int,  power : Int, modulus : Int ) : Int {
        
        AssertBoolEqual( power >= 0, true, "`power` must be non-negative" );
        AssertBoolEqual( modulus > 0, true, "`modulus` must be positive" );
        AssertBoolEqual( expBase > 0, true, "`expBase` must be positive" );

        mutable res = 1;
        mutable expPow2mod = expBase;
        // express p as bit-string pₙ … p₀ 
        let powerBitExpansion = BoolArrFromPositiveInt(power,BitSize(power));
        let expBaseMod = expBase % modulus;

        for( k in 0 .. Length(powerBitExpansion) - 1 )
        {
            if( powerBitExpansion[k] ) {
                // if bit pₖ is 1, multiply res by expBase^(2ᵏ) (mod `modulus`)
                set res = (res * expPow2mod) % modulus;
            }
            // update value of expBase^(2ᵏ) (mod `modulus`)
            set expPow2mod = expPow2mod * expPow2mod % modulus;
        }
        return res;
    }

    /// # Summary
    /// Computes tuple (u,v) such that u⋅a + v⋅b = GCD(a,b), where GCD is a
    /// greatest common divisor of a and b. The GCD is always positive.
    ///
    /// # Input
    /// ## a
    /// the first number of which extended greatest common divisor is being computed
    /// ## b
    /// the second number of which extended greatest common divisor is being computed
    ///
    /// # Output
    /// Tuple (u,v) with properties u⋅a + v⋅b = GCD(a,b)
    ///
    /// # References
    /// - This implementation is according to https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
    function ExtendedGCD( a : Int, b : Int ) : (Int, Int) {
        let signA = SignI(a);
        let signB = SignI(b);
        mutable s = (1, 0);
        mutable t = (0, 1);
        mutable r = (a*signA, b*signB);
        repeat {}
        until( Snd(r) == 0 )
        fixup {
            let quotient = Fst(r) / Snd(r);
            set r = ( Snd(r), Fst(r) - quotient * Snd(r) );
            set s = ( Snd(s), Fst(s) - quotient * Snd(s) );
            set t = ( Snd(t), Fst(t) - quotient * Snd(t) );
        }
        return (Fst(s)*signA,Fst(t)*signB);
    }

    /// # Summary
    /// Represents an integer of the form p/q. Integer p is
    /// the first element of the tuple and q is the second element
    /// of the tuple.
    newtype Fraction = (Int,Int);

    /// # Summary
    /// Computes greatest common divisor of a and b. The GCD is always positive.
    ///
    /// # Input
    /// ## a
    /// the first number of which extended greatest common divisor is being computed
    /// ## b
    /// the second number of which extended greatest common divisor is being computed
    ///
    /// # Output
    /// Greatest common divisor of a and b
    function GCD( a : Int, b : Int ) : Int { 
        let (u,v) = ExtendedGCD(a,b);
        return u*a + v*b;
    }

    /// # Summary 
    /// Finds a continued fraction convergent closest to `fraction` 
    /// with the denominator less or equal to `denominatorBound` 
    /// 
    /// # Input 
    /// 
    /// 
    /// # Output 
    /// Continued fraction closest to `fraction` 
    /// with the denominator less or equal to `denominatorBound` 
    function ContinuedFractionConvergent ( fraction : Fraction, denominatorBound : Int  )
        : Fraction {

        AssertBoolEqual(denominatorBound > 0, true, "Denominator bound must be positive" );

        let (a,b) = fraction;
        let signA = SignI(a);
        let signB = SignI(b);
        mutable s = (1, 0);
        mutable t = (0, 1);
        mutable r = (a*signA, b*signB);
        repeat {}
        until( Snd(r) == 0 || AbsI(Snd(s)) > denominatorBound )
        fixup {
            let quotient = Fst(r) / Snd(r);
            set r = ( Snd(r), Fst(r) - quotient * Snd(r) ); 
            set s = ( Snd(s), Fst(s) - quotient * Snd(s) ); 
            set t = ( Snd(t), Fst(t) - quotient * Snd(t) ); 
        }

        if( Snd(r) == 0  && AbsI(Snd(s)) <= denominatorBound ) {
            return Fraction(-Snd(t)*signB, Snd(s)*signA);
        }

        return Fraction(-Fst(t)*signB, Fst(s)*signA);
    }

    /// # Summary 
    /// Returns  true if a and b are co-prime and false otherwise.
    ///
    /// # Input
    /// ## a
    /// the first number of which co-primality is being tested
    /// ## b
    /// the second number of which co-primality is being tested
    ///
    /// # Output
    /// True, if a and b are co-prime (e.g. their greatest common divisor is 1 ),
    /// and false otherwise
    function IsCoprime( a : Int, b : Int ) : Bool {
        let (u,v) = ExtendedGCD(a,b);
        return u*a + v*b == 1;
    }

    /// # Summary
    /// Returns b such that `a`⋅b = 1 (mod `modulus`)
    ///
    /// # Input
    /// ## a
    /// The number being inverted
    /// ## modulus
    /// The modulus according to which the numbers are inverted
    ///
    /// # Output
    /// Integer b such that a⋅`b` = 1 (mod `modulus`)
    function InverseMod( a : Int, modulus : Int ) : Int {
        let (u,v) = ExtendedGCD(a,modulus);
        let gcd = u*a + v*modulus;
        AssertBoolEqual(
            gcd == 1,
            true, "`a` and `modulus` must be co-prime" );
        return Modulus(u,modulus);
    }

    /// # Summary
    /// For non-negative integer `a` returns the smallest n such
    /// that a < 2ⁿ .
    ///
    /// # Input
    /// ## a
    /// The integer bit-size of which is computed.
    ///
    /// # Output
    /// The bit-size of `a`
    function BitSize( a : Int ) : Int {
        AssertBoolEqual(a >= 0 , true, "`a` must be non-negative");
        mutable bitsize = 0;
        mutable val = a;
        repeat{}
        until( val == 0 )
        fixup { 
            set bitsize = bitsize + 1;
            set val = val / 2;
        }
        return bitsize;
    }
}
