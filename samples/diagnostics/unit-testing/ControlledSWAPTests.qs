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
    /// This is an utility operation used to collect gate counts, depth etc of the circuit
    /// # Input
    /// ## op
    /// Any operation that maps |000⟩ to |000⟩
    /// # See Also
    /// - CircuitMetrics.cs
    operation CollectMetrics(op : ((Qubit, Qubit, Qubit) => Unit is Adj)) : Unit {
        use qubits = Qubit[3];
        op(qubits[0], qubits[1], qubits[2]);
    }
    
    
    /// # Summary
    /// This operation tests correctness of the implementations of ControlledSWAP
    /// also known as Fredkin gate.
    operation ControlledSWAPTest () : Unit {
        
        // Now proceed to test the equality of operations
        let equalTestList = [(ApplyControlledSWAPUsingCCNOT(TDepthOneCCNOT, _, _, _), ApplyBuiltInControlledSWAP), (ApplyControlledSWAPUsingCCNOT(CCNOT, _, _, _), ApplyBuiltInControlledSWAP), (ApplyControlledSWAPUsingExplicitDecomposition, ApplyBuiltInControlledSWAP)];
        
        for (actual, expected) in equalTestList {
            
            // This ensures that we have a list of tested circuits in the output
            // If the test fails the circuit that is wrong will be the last one in the list
            Message($"Testing if {actual} is equal to {expected}.");
            
            // this checks that gates are equal
            AssertOperationsEqualInPlace(3, ApplyToFirstThreeQubits(actual, _), ApplyToFirstThreeQubitsA(expected, _));
            
            // We used partial application and ApplyToFirstThreeQubits to convert operation with
            // signature (Qubit,Qubit,Qubit) => () to operation with signature Qubit[] => ()
            
            // The operation below is used for metrics collection, for more detail
            // see CircuitMetrics.cs
            CollectMetrics(actual);
        }
    }
    
}


