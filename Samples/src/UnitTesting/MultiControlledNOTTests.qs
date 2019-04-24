// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.UnitTesting {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;


    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Unit test for circuits implementing Multiply Controlled Not gates
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // As our test operations expect operations with signature (Qubit[] => ()),
    // we need a helper to map our MultiControlledX1 with signature ((Qubit[],Qubit) => ())
    // to an operation with signature (Qubit[] => ())
    operation ControlledTestHelper (op : ((Qubit[], Qubit) => Unit is Adj), target : Qubit[]) : Unit {

        body (...) {
            Fact(Length(target) >= 1, "The length of the target must be >= 1 ");
            op(target[1 .. Length(target) - 1], target[0]);
        }

        adjoint invert;
    }


    /// # Summary
    /// Tests correctness of MultiControlledNot implementations
    operation MultiControlledNotTest () : Unit {

        //  list of the operations to test in format (actual,expected)
        let testList = [(MultiControlledXClean, Controlled X), (MultiControlledXBorrow, Controlled X)];

        for (i in 0 .. Length(testList) - 1) {
            let (actual, expected) = testList[i];

            for (totalNumberOfQubits in 1 .. 8) {
                Message($"Testing {actual} against {expected} on {totalNumberOfQubits} qubits.");

                // We use AssertOperationsEqualReferenced as it requires only
                // one call to the operation being tested
                AssertOperationsEqualReferenced(totalNumberOfQubits, ControlledTestHelper(actual, _), ControlledTestHelper(expected, _));
            }
        }
    }


    /// # Summary
    /// Lets us collect metrics related to borrowing
    operation MultiControlledNotWithDirtyQubitsMetrics (numberOfControlQubits : Int) : Unit {

        using (extraQubits = Qubit[numberOfControlQubits - 2]) {
            ApplyToEach(H, extraQubits);

            using (qubits = Qubit[numberOfControlQubits + 1]) {

                // first use multiply controlled not with borrowing qubits
                MultiControlledXBorrow(qubits[0 .. numberOfControlQubits - 1], qubits[numberOfControlQubits]);

                // second use multiply controlled not with clean qubits allocation
                MultiControlledXClean(qubits[0 .. numberOfControlQubits - 1], qubits[numberOfControlQubits]);
            }

            ApplyToEach(H, extraQubits);
        }
    }


    /// # Summary
    /// Tests correctness of MultiControlledNot implementations
    /// in the presence of dirty qubits.
    operation MultiControlledNotWithDirtyQubitsTest () : Unit {

        // Now let us test MultiControlledXBorrow with dirty qubits.
        // The non-trivial circuit is used starting 3 controls
        for (numberOfControlQubits in 3 .. 7) {

            // MultiControlledXBorrow uses numberOfControlQubits - 2 dirty qubits
            using (extraQubits = Qubit[numberOfControlQubits - 2]) {
                ApplyToEach(H, extraQubits);
                AssertOperationsEqualReferenced(numberOfControlQubits + 1, ControlledTestHelper(MultiControlledXBorrow, _), ControlledTestHelper(Controlled X, _));
                ApplyToEach(H, extraQubits);
            }
        }
    }

}


