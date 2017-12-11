// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Canon;
   
	function IsEven(element : Int) : Bool {		
		return (element % 2) == 0;
	} 

	function IsSingleDigit(element : Int) : Bool {
		return (element >= 0) && (element < 10);
	}

	function Add(input : (Int, Int)) : Int {
		let (first, second) = input;
		return first + second;
	}

	function Squarer(a: Int) : Int {
		return a * a;
	}

	function ForAllTest() : () {
		AssertBoolEqual(ForAll(IsSingleDigit, [3; 4; 7; 8]), true, "the elements [3; 4; 7; 8] were not found to be single digit numbers.");
		AssertBoolEqual(ForAll(IsSingleDigit, [3; 4; 7; 18]), false, "the elements [3; 4; 7; 18] were found to be single digit numbers.");
	}

	function ForAnyTest() : () {
		AssertBoolEqual(ForAny(IsEven, [3; 7; 99; -4]), true, "the elements [3; 7; 99; -4] were not found to contain at least one even number.");			
		AssertBoolEqual(ForAny(IsEven, [3; 7; 99; -41]), false, "the elements [3; 7; 99; -4] were not found to contain at least one even number.");			
	}

	function FoldTest() : () {
		let array = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10];
		AssertIntEqual(Fold(Add, 0, array), 55, "folding the summation over [1..10] did not yield 55.");	
	}

	function MapTest() : () {
		let array = [1; 2; 3; 4];
		let squaredArray = Map(Squarer, array); 
		AssertIntEqual(Fold(Add, 0, squaredArray), 30, "the sum of the squares of [1; 2; 3; 4] was not found to be 30.");
	}

    function ExtremaTest() : () {
        let array = [-10; 10; 7; 0];
        AssertIntEqual(-10, Min(array), "Min failed.");
        AssertIntEqual(10, Max(array), "Max failed.");
    }

}
