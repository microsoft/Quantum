// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;

    function NativeFnsAreCallableTest() : () {
        let arg = PI() / 2.0;
        AssertAlmostEqual(Sin(arg), 1.0);
        AssertAlmostEqual(Cos(arg), 0.0);

        let arcArg = 1.0;
        AssertAlmostEqual(ArcCos(arcArg), 0.0);
        AssertAlmostEqual(ArcSin(arcArg), arg);
    }

    function RealModTest() : () {
        AssertAlmostEqual(RealMod(5.5 * PI(), 2.0 * PI(), 0.0), 1.5 * PI());
        AssertAlmostEqual(RealMod(0.5 * PI(), 2.0 * PI(), -PI() / 2.0), 0.5 * PI());
    }

    function ArcHyperbolicFnsTest() : () {
        // These tests were generated using NumPy's implementations
        // of the inverse hyperbolic functions.
        AssertAlmostEqual(ArcTanh(0.3), 0.30951960420311175);
        AssertAlmostEqual(ArcCosh(1.3), 0.75643291085695963);
        AssertAlmostEqual(ArcSinh(-0.7), -0.65266656608235574);
    }

    function ExtendedGCDTestHelper(  a : Int , b : Int, gcd : Int ) : () {
        Message($"Testing {a}, {b}, {gcd} ");
        let (u,v) = ExtendedGCD(a,b);
        let expected = AbsI(gcd);
        let actual = AbsI(u*a+v*b);
        AssertIntEqual( expected, actual,
            $"Expected absolute value of gcd to be {expected}, got {actual}");
    }

    function ExtendedGCDTest() : ()
    {
        let testTuples = [ (1,1,1); (1,-1,1); (-1,1,1); (-1,-1,1); (5,7,1); (-5,7,1); (3,15,3) ];
        Ignore(Map(ExtendedGCDTestHelper, testTuples));
    }

	function BitSizeTest() : () {
		AssertIntEqual(BitSize(3),2,"BitSize(3) must be 2");
		AssertIntEqual(BitSize(7),3,"BitSize(7) must be 2");
	}

	function ExpModTest() : () {
		// this test is generated using Mathematica PowerMod function
		let result = ExpMod(5,4611686018427387903,7);
		AssertIntEqual(result,6, $"The result must be 6, got {result}");
	}

	function ContinuedFractionConvergentTestHelper( numerator : Int, denominator : Int ) : () {
		let bitSize = 2 * BitSize(denominator);
		let numeratorDyadic = numerator * 2 ^ bitSize / denominator;
		let (u,v) = ContinuedFractionConvergent( Fraction(numeratorDyadic, 2^bitSize), denominator );
		AssertBoolEqual(
			(AbsI(u) == numerator ) &&  (AbsI(v) == denominator ) , true,
			$"The result must be ±{numerator}/±{denominator} got {u}/{v}");
	}

	function ContinuedFractionConvergentEdgeCaseTestHelper( numerator : Int, denominator : Int, bound : Int ) : () {
		let (num,denom) = ContinuedFractionConvergent( Fraction(numerator,denominator), bound );
		AssertBoolEqual(
			( AbsI(num) == numerator ) &&  ( AbsI(denom) == denominator ) , true,
			$"The result must be ±{numerator}/±{denominator} got {num}/{denom}");
	}

	function ContinuedFractionConvergentTest() : () {
		let testTuples = [ (29,47); (17,37); (15,67) ];
		Ignore(Map(ContinuedFractionConvergentTestHelper, testTuples));
		let edgeCaseTestTuples = [ (1,4,512); (3,4,512) ];
		Ignore(Map(ContinuedFractionConvergentEdgeCaseTestHelper, edgeCaseTestTuples));
	}
}
