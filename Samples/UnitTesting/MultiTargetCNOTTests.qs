// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Testing;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Unit test for circuits implementing Multi Target Multiply Controlled Not gates
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary 
    /// Tests correctness of MultiTargetMultiNot implementations
    operation MultiTargetMultiControlledNotTest() : () {
        body {
            //  list of the operations to test in format (actual,expected)
            let testList = [
                (MultiTargetMultiNot,Controlled(MultiX))
            ];

            for( i in 0 .. Length(testList) - 1 ) {
                let (actual,expected) = testList[i];
                for( totalNumberOfQubits in 1 .. 8 ) {
                    // We use AssertOperationsEqualReferenced as it requires only 
                    // one call to the operation being tested
                    // when the number of controls is one 
                    // the test will cover MultiTargetNot function 
                    for( numberOfControls in 1 .. totalNumberOfQubits - 1 ) {
                        let msg1 = $"Testing {actual} against {expected} ";
                        let msg2 = $" on {totalNumberOfQubits} with {numberOfControls} controls";
                        Message(msg1 + msg2);
                        AssertOperationsEqualReferenced(
                            ApplyToPartitionCA(actual, numberOfControls, _),
                            ApplyToPartitionCA(expected, numberOfControls, _),
                            totalNumberOfQubits );
                    }
                }
            }
        }
    }
}
