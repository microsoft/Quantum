// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    function IsEven (element : Int) : Bool {

        return element % 2 == 0;
    }


    function IsSingleDigit (element : Int) : Bool {

        return element >= 0 and element < 10;
    }


    function Add (input : (Int, Int)) : Int {

        let (first, second) = input;
        return first + second;
    }


    function Squarer (a : Int) : Int {
        return a * a;
    }


    function AllTest () : Unit {
        Fact(All(IsSingleDigit, [3, 4, 7, 8]), "the elements [3, 4, 7, 8] were not found to be single digit numbers.");
        Fact(not All(IsSingleDigit, [3, 4, 7, 18]), "the elements [3, 4, 7, 18] were found to be single digit numbers.");
    }


    function AnyTest () : Unit {
        Fact(Any(IsEven, [3, 7, 99, -4]), "the elements [3, 7, 99, -4] were not found to contain at least one even number.");
        Fact(not Any(IsEven, [3, 7, 99, -41]), "the elements [3, 7, 99, -41] were erroneously found to contain at least one even number.");
    }


    function FoldTest () : Unit {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        EqualityFactI(Fold(Add, 0, array), 55, "folding the summation over [1..10] did not yield 55.");
    }


    function MapTest () : Unit {
        let array = [1, 2, 3, 4];
        let squaredArray = Mapped(Squarer, array);
        EqualityFactI(Fold(Add, 0, squaredArray), 30, "the sum of the squares of [1, 2, 3, 4] was not found to be 30.");
    }


    function ExtremaTest () : Unit {

        let array = [-10, 10, 7, 0];
        EqualityFactI(-10, Min(array), "Min failed.");
        EqualityFactI(10, Max(array), "Max failed.");
    }

}


