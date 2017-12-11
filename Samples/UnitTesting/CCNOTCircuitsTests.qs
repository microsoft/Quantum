// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.UnitTesting {

    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Unit test for circuits implementing Controlled SWAP gate, also known as Fredkin gate
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary 
    /// This operation tests correctness of the implementation of Doubly Controlled X gates
    /// also known as Toffoli gates.
    operation CCNOTCiruitsTest() : () {
        body {
            
            //  List of pairs of operations (expected,actual) to be tested up to a phase
            let upToPhaseTestList = [
                (UpToPhaseCCNOT1,CCNOT);
                (UpToPhaseCCNOT2,CCNOT);
                (UpToPhaseCCNOT3,CCNOT)
            ];

            for( i in 0 .. Length(upToPhaseTestList)-1 )
            {
                let (actual,expected) = upToPhaseTestList[i];
                // This ensures that we have a list of tested circuits in the output
                // If the test fails the circuit that is wrong will be the last one in the list
                Message($"Testing {actual} against {expected} up to phases.");
                // this checks that gates in the list act the same on all the 
                // computational basis states ( up to a global phase )
                AssertOperationsEqualInPlaceCompBasis(
                    ApplyToFirstThreeQubits(actual,_),
                    ApplyToFirstThreeQubitsA(expected,_),3);
                // We used partial application and ApplyToFirstThreeQubits to convert operation with 
                // signature (Qubit,Qubit,Qubit) => () to operation with signature Qubit[] => ()

                // The operation below is used for metrics collection, for more detail see 
                // CircuitMetrics.cs
                CollectMetrics(actual);
            }

            // Now proceed to test the equality of operations
            let equalTestList = [
                (UpToPhaseCCNOT2,UpToPhaseCCNOT3);
                (CCNOT1, CCNOT);
                (CCNOT2, CCNOT);
                (CCNOT3, CCNOT);
                (CCNOT4, CCNOT);
                (TDepthOneCCNOT, CCNOT)
            ];

            for( i in 0 .. Length(equalTestList)-1 )
            {
                let (actual,expected) = equalTestList[i];
                // This ensures that we have a list of tested circuits in the output
                // If the test fails the circuit that is wrong will be the last one in the list
                Message($"Testing if {actual} is equal to {expected}.");
                // this checks that gates are equal
                AssertOperationsEqualReferenced(
                    ApplyToFirstThreeQubits(actual,_),
                    ApplyToFirstThreeQubitsA(expected,_),3);
                // We used partial application and ApplyToFirstThreeQubits to convert operation with 
                // signature (Qubit,Qubit,Qubit) => () to operation with signature Qubit[] => ()

                // The operation below is used for metrics collection, 
                // for more detail see CircuitMetrics.cs
                CollectMetrics(actual);
            }
        }
    }   
}
