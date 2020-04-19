// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;


    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Unit test for circuits implementing Controlled SWAP gate, also known as Fredkin gate
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// This operation tests correctness of the implementation of Doubly Controlled X gates
    /// also known as Toffoli gates.
    operation CCNOTCircuitsTest () : Unit {

        //  List of pairs of operations (expected,actual) to be tested up to a phase
        let upToPhaseTestList = [(UpToPhaseCCNOT1, CCNOT), (UpToPhaseCCNOT2, CCNOT), (UpToPhaseCCNOT3, CCNOT)];

        for ((actual, expected) in upToPhaseTestList) {

            // This ensures that we have a list of tested circuits in the output
            // If the test fails the circuit that is wrong will be the last one in the list
            Message($"Testing {actual} against {expected} up to phases.");

            // this checks that gates in the list act the same on all the
            // computational basis states ( up to a global phase )
            AssertOperationsEqualInPlaceCompBasis(3, ApplyToFirstThreeQubits(actual, _), ApplyToFirstThreeQubitsA(expected, _));

            // We used partial application and ApplyToFirstThreeQubits to convert operation with
            // signature (Qubit,Qubit,Qubit) => () to operation with signature Qubit[] => ()

            // The operation below is used for metrics collection, for more detail see
            // CircuitMetrics.cs
            CollectMetrics(actual);
        }

        // Now proceed to test the equality of operations
        let equalTestList = [(UpToPhaseCCNOT2, UpToPhaseCCNOT3), (CCNOT1, CCNOT), (CCNOT2, CCNOT), (CCNOT3, CCNOT), (CCNOT4, CCNOT), (TDepthOneCCNOT, CCNOT)];

        for ((actual, expected) in equalTestList) {

            // This ensures that we have a list of tested circuits in the output
            // If the test fails the circuit that is wrong will be the last one in the list
            Message($"Testing if {actual} is equal to {expected}.");

            // this checks that gates are equal
            AssertOperationsEqualReferenced(3, ApplyToFirstThreeQubits(actual, _), ApplyToFirstThreeQubitsA(expected, _));

            // We used partial application and ApplyToFirstThreeQubits to convert operation with
            // signature (Qubit,Qubit,Qubit) => () to operation with signature Qubit[] => ()

            // The operation below is used for metrics collection,
            // for more detail see CircuitMetrics.cs
            CollectMetrics(actual);
        }
    }

}


