// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.UnitTesting {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;


    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Unit test for circuits implementing Multi Target Multiply Controlled Not gates
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// Tests correctness of MultiTargetMultiNot implementations
    @Test("QuantumSimulator")
    operation CheckMultiTargetMultiControlledNotIsCorrect() : Unit {
        // list of the operations to test in format (actual, expected)
        let testList = [
            (ApplyMultiTargetMultiNot, Controlled (ApplyToEachCA(X, _)))
        ];

        for (actual, expected) in testList {
            for totalNumberOfQubits in 1 .. 8 {
                // We use AssertOperationsEqualReferenced as it requires only
                // one call to the operation being tested
                // when the number of controls is one
                // the test will cover MultiTargetNot function
                for numberOfControls in 1 .. totalNumberOfQubits - 1 {
                    Message(
                        $"Testing {actual} against {expected} " +
                        $"on {totalNumberOfQubits} with {numberOfControls} controls."
                    );
                    AssertOperationsEqualReferenced(totalNumberOfQubits,
                        ApplyToPartitionCA(actual, numberOfControls, _),
                        ApplyToPartitionCA(expected, numberOfControls, _)
                    );
                }
            }
        }
    }

}
