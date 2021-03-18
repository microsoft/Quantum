// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    function IsEven(element : Int) : Bool {
        return element % 2 == 0;
    }

    function IsSingleDigit(element : Int) : Bool {
        return element >= 0 and element < 10;
    }

    function Squared(a : Int) : Int {
        return a * a;
    }


    @Test("QuantumSimulator")
    function AllIsCorrect() : Unit {
        Fact(All(IsSingleDigit, [3, 4, 7, 8]), "the elements [3, 4, 7, 8] were not found to be single digit numbers.");
        Contradiction(All(IsSingleDigit, [3, 4, 7, 18]), "the elements [3, 4, 7, 18] were found to be single digit numbers.");
    }


    @Test("QuantumSimulator")
    function AnyIsCorrect() : Unit {
        Fact(Any(IsEven, [3, 7, 99, -4]), "the elements [3, 7, 99, -4] were not found to contain at least one even number.");
        Contradiction(Any(IsEven, [3, 7, 99, -41]), "the elements [3, 7, 99, -41] were erroneously found to contain at least one even number.");
    }


    @Test("QuantumSimulator")
    function FoldIsCorrect() : Unit {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        EqualityFactI(Fold(PlusI, 0, array), 55, "folding the summation over [1..10] did not yield 55.");
    }


    @Test("QuantumSimulator")
    function MappedIsCorrect() : Unit {
        let array = [1, 2, 3, 4];
        let squaredArray = Mapped(Squared, array);
        EqualityFactI(Fold(PlusI, 0, squaredArray), 30, "the sum of the squares of [1, 2, 3, 4] was not found to be 30.");
    }


    @Test("QuantumSimulator")
    function MinAndMaxAreCorrect() : Unit {
        let array = [-10, 10, 7, 0];
        EqualityFactI(-10, Min(array), "Min failed.");
        EqualityFactI(10, Max(array), "Max failed.");
    }

}


