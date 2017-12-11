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
    /// This is an utility operation used to collect gate counts, depth etc of the circuit
    /// # Input 
    /// ## op
    /// Any operation that maps |000⟩ to |000⟩
    /// # See Also 
    /// - CircuitMetrics.cs
    operation CollectMetrics( op : ( (Qubit,Qubit,Qubit) => () : Adjoint ) ) : () {
        body {
            using ( qubits = Qubit[3] ) {
                op(qubits[0],qubits[1],qubits[2]);
            }
        }
    }

    /// # Summary 
    /// This operation tests correctness of the implementations of ControlledSWAP
    /// also known as Fredkin gate.
    operation ControlledSWAPTest() : () {
        body {

            // Now proceed to test the equality of operations
            let equalTestList = [
                (ControlledSWAPUsingCCNOT(TDepthOneCCNOT,_,_,_),ControlledSWAP0);
                (ControlledSWAPUsingCCNOT(CCNOT,_,_,_),ControlledSWAP0);
                (ControlledSWAP1, ControlledSWAP0)
            ];

            for( i in 0 .. Length(equalTestList)-1 )
            {
                let (actual,expected) = equalTestList[i];
                
                // This ensures that we have a list of tested circuits in the output
                // If the test fails the circuit that is wrong will be the last one in the list
                Message($"Testing if {actual} is equal to {expected}.");

                // this checks that gates are equal
                AssertOperationsEqualInPlace(
                    ApplyToFirstThreeQubits(actual,_),
                    ApplyToFirstThreeQubitsA(expected,_),3);
                
                // We used partial application and ApplyToFirstThreeQubits to convert operation with 
                // signature (Qubit,Qubit,Qubit) => () to operation with signature Qubit[] => ()

                // The operation below is used for metrics collection, for more detail 
                // see CircuitMetrics.cs
                CollectMetrics(actual);
            }
        }
    }   
}
