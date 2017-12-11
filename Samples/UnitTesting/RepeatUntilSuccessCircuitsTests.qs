// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Canon;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Unit test to circuits implementing for exp(±i⋅ArcTan(2)⋅Z) with using Repeat-Until-Success
    // (RUS) protocols. Note that all test operations names end with `Test`
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// Here we check the correctness of Repeat Until Success unitary circuits
    /// defined in RepeatUntilSuccessCircuits.qs.
    operation RepeatUntilSuccessCircuitsTest () : () {
        body {
            // List of operations to test (actual,expected)
            // we first test ExpIZArcTan2NC and its Adjoint
            // next test ExpIZArcTan2PS and its Adjoint
            let testList = [ 
                (ExpIZArcTan2NC, Exp([PauliZ],ArcTan(2.0),_) );
                (Adjoint(ExpIZArcTan2NC), Exp([PauliZ],-ArcTan(2.0),_) );
                (ExpIZArcTan2PS, Exp([PauliZ],ArcTan(2.0),_) );
                (Adjoint(ExpIZArcTan2PS), Exp([PauliZ],-ArcTan(2.0),_) )
            ];

            // As the circuits are probabilistic we repeat tests multiple times
            for( i in 0 .. 400 ) {
                // next go over everything in testList
                for( j in 0 .. Length(testList) - 1 ) {
                    let (actual,expected) = testList[j];
                    // This will log the names and parameters of operations being tested
                    Message($"Testing {actual} against {expected}. Attempt: {i}");
                    // Using Referenced testing, as it uses only one call to the operation
                    // Note that in QCTraceSimulator call graph
                    // ExpIZArcTan2NC and ExpIZArcTan2PS will be called from ApplyToFirstQubit
                    AssertOperationsEqualReferenced(
                        ApplyToFirstQubit(actual,_),
                        expected,1);
                }
            }
        }
    }
    
    /// # Summary
    /// Here we check the correctness of Repeat Until Success state preparation circuit
    /// defined in RepeatUntilSuccessCircuits.qs.
    operation RepeatUntilSuccessStatePreparationTest () : () {
        body {
            for( i in 0 .. 100 ) {
                using( qubits = Qubit[1] ) {
                    let target = qubits[0];
                    
                    // Prepare input in |+⟩ state
                    H(target);
                    
                    // Apply function being tested
                    RepeatUntilSuccessStatePreparation(target);

                    // Assert that prepared state is (√2/√3,1/√3)
                    let zeroAmp = Complex( Sqrt(2.0) / Sqrt(3.0), 0.0 );
                    let oneAmp = Complex( ToDouble(1) / Sqrt(3.0), 0.0 );
                    AssertQubitState(
                        ( zeroAmp, oneAmp),
                        target,
                        1e-10 );
                    
                    // Reset target back to |0⟩
                    Reset(target);
                }

            }
        }
    }
}
