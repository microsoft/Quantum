// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;

    /// # Summary 
    /// Tests multiply controlled not implementation that uses 
    /// ApplyMultiControlledCA against multiply controlled version of 
    /// the Microsoft.Quantum.Primitive.X
    operation ApplyMultiControlledTest () : () {
        body {
            let twoQubitOp = CNOT;

            // this gives us operation ( controls : Qubit[], targets : Qubit[] ) => ()
            // where we expect targets to have length 2
            let multiControlledCNOT = Controlled(ApplyToFirstTwoQubitsCA(twoQubitOp,_));
            
            // this gives up operation ( qubits : Qubit[] ) => ()
            // where first qubit in qubits is control and the rest are target for 
            // twoQubitOp
            let singlyControlledCNOT = ApplyToPartitionCA(multiControlledCNOT,1,_);
            
            // Construct multiply controlled op using its singly controlled version 
            // with the help of ApplyMultiControlledCA
            let canonMultiNot = 
                ApplyMultiControlledCA( singlyControlledCNOT, CCNOTop(CCNOT), _, _ );

            for( numberOfcontrols in 1 .. 5  )
            {
                Message($"Checking the equality with {numberOfcontrols} controls");
                // construct actual and expected with desired number of controls
                let actual = ApplyToPartitionCA(canonMultiNot,numberOfcontrols,_);
                let expected = ApplyToPartitionCA(multiControlledCNOT,numberOfcontrols,_);
                // check equality 
                AssertOperationsEqualReferenced(actual,expected,numberOfcontrols+2);
            }
        }
    }
}
