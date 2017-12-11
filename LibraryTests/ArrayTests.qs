// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;

    function ZipTest() : () {
        let left = [1; 2; 101];
        let right = [PauliY; PauliI];
        let zipped = Zip(left, right);

        let (leftActual1, rightActual1) = zipped[0];
        if (leftActual1 != 1 || rightActual1 != PauliY) {
            fail $"Expected (1, PauliY), got ({leftActual1}, {rightActual1}).";
        }

        let (leftActual2, rightActual2) = zipped[1];
        if (leftActual2 != 2 || rightActual2 != PauliI) {
            fail $"Expected (2, PauliI), got ({leftActual2}, {rightActual2}).";
        }
    }

    function LookupTest() : () {
        let array = [1; 12; 71; 103];
        let fn = LookupFunction(array);
        AssertIntEqual(fn(0), 1, "fn(0) did not return array[0]");
        // Make sure we can call in random order!
        AssertIntEqual(fn(3), 103, "fn(3) did not return array[3]");
        AssertIntEqual(fn(2), 71, "fn(2) did not return array[2]");
        AssertIntEqual(fn(1), 12, "fn(1) did not return array[1]");
    }

    function ConstantArrayTestHelper(x : Int) : Int {
        return x * x;
    }

    function ConstantArrayTest() : () {
        let dblArray = ConstantArray(71, 2.17);
        AssertIntEqual(Length(dblArray), 71, "ConstantArray(Int, Double) had the wrong length.");
        let ignore = Map(AssertAlmostEqual(_, 2.17), dblArray);
        // Stress test by making an array of Int -> Int.
        let fnArray = ConstantArray(7, ConstantArrayTestHelper);
        AssertIntEqual(Length(fnArray), 7, "ConstantArray(Int, Int -> Int) had the wrong length.");
        AssertIntEqual((fnArray[3])(7), 49, "ConstantArray(Int, Int -> Int) had the wrong value.");
    }

	function SubarrayTest() : () {
		let array0 = [0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 10];
		let subarrayOdd = Subarray([1; 3; 5; 7; 9], array0);
		let subarrayEven = Subarray([0; 2; 4; 6; 8; 10], array0);
		AssertBoolEqual(ForAll(IsEven, subarrayEven), true, "the even elements of [1..10] were not correctly sliced.");
		AssertBoolEqual(ForAny(IsEven, subarrayOdd), false, "the odd elements of [1..10] were not correctly sliced.");

        let array1 = [10; 11; 12; 13];
        Ignore(Map(AssertIntEqual(_, _, "Subarray failed: subpermutation case."), Zip([12; 11], Subarray([2; 1], array1))));
	}

	function FilterTest() : () {
		let array = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10];
		let evenArray = Filter(IsEven, array);
		AssertBoolEqual(ForAll(IsEven, evenArray), true, "the even elements of [1..10] were not correctly filtered.");
	}

    function ReverseTest() : () {
        let array = [1; 2; 3];
        Ignore(Map(AssertIntEqual(_, _, "Reverse failed."), Zip([3; 2; 1], Reverse(array))));
    }

    function ExcludeTest() : () {
        let array = [10; 11; 12; 13; 14; 15];
        Ignore(Map(AssertIntEqual(_, _, "Exclude failed."), Zip([10; 11; 13; 14], Exclude([2; 5], array))));
    }
}
