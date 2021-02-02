// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.UnitTesting {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;


    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Unit test for circuits implementing Multiply Controlled Not gates
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // As our test operations expect operations with signature (Qubit[] => ()),
    // we need a helper to map our MultiControlledX1 with signature ((Qubit[],Qubit) => ())
    // to an operation with signature (Qubit[] => ())
    operation ControlledTestHelper (op : ((Qubit[], Qubit) => Unit is Adj), target : Qubit[]) : Unit is Adj {
            Fact(Length(target) >= 1, "The length of the target must be >= 1 ");
            op(target[1 .. Length(target) - 1], target[0]);
    }


    /// # Summary
    /// Tests correctness of MultiControlledNot implementations
    operation MultiControlledNotTest () : Unit {

        //  list of the operations to test in format (actual,expected)
        for (actual, expected) in [(ApplyMultiControlledXByUsing, Controlled X), (ApplyMultiControlledXByBorrowing, Controlled X)] {
            for totalNumberOfQubits in 1 .. 8 {
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
        use extraQubits = Qubit[numberOfControlQubits - 2];
        within {
            ApplyToEachCA(H, extraQubits);
        } apply {
            use qubits = Qubit[numberOfControlQubits + 1];
            // first use multiply controlled not with borrowing qubits
            ApplyMultiControlledXByBorrowing(MostAndTail(qubits));

            // second use multiply controlled not with clean qubits allocation
            ApplyMultiControlledXByUsing(MostAndTail(qubits));
        }
    }


    /// # Summary
    /// Tests correctness of MultiControlledNot implementations
    /// in the presence of dirty qubits.
    operation MultiControlledNotWithDirtyQubitsTest () : Unit {

        // Now let us test MultiControlledXBorrow with dirty qubits.
        // The non-trivial circuit is used starting 3 controls
        for numberOfControlQubits in 3 .. 7 {
            // MultiControlledXBorrow uses numberOfControlQubits - 2 dirty qubits
            use extraQubits = Qubit[numberOfControlQubits - 2];
            within {
                ApplyToEachCA(H, extraQubits);
            } apply {
                AssertOperationsEqualReferenced(numberOfControlQubits + 1, ControlledTestHelper(ApplyMultiControlledXByBorrowing, _), ControlledTestHelper(Controlled X, _));
            }
        }
    }

}


