// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// If the Teleportation circuit is correct this operation must be an identity
    operation TeleportationIdentityTestHelper (arg : Qubit[]) : Unit {

        EqualityFactI(Length(arg), 1, "Helper is defined only on single qubit input");

        using (auxillary = Qubit()) {
            Teleportation(arg[0], auxillary);
            SWAP(arg[0], auxillary);
        }
    }

    /// # Summary
    /// Tests the correctness of the teleportation circuit from Teleportation.qs
    operation TeleportationTest () : Unit {

        // given that there is randomness involved in the Teleportation,
        // repeat the tests several times.
        for (idxIteration in 1 .. 8) {
            for (assertion in [AssertOperationsEqualInPlace, AssertOperationsEqualReferenced]) {
                assertion(1, TeleportationIdentityTestHelper, NoOp<Qubit[]>);
            }
        }
    }

}


