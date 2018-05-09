// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Testing;

    function ComposeTest() : () {
        let target = [3; 17; 2];
        AssertIntEqual(
            (Compose(Modulus(_, 14), Max))(target),
            3,
            "Compose(Modulus(_, 14), Max) did not return expected result."
        );
    }

    operation WithTest() : () {
        body {
            let actual = With(H, X, _);
            let expected = Z;

            AssertOperationsEqualReferenced(ApplyToEach(actual, _), ApplyToEachA(expected, _), 4);
    	}
    }

    // Make sure that if CurryTest fails, it's because of Curry and not
    // something else.
    operation CurryPreTest() : () {
        body {
            AssertOperationsEqualInPlace(Exp([PauliZ], 1.7, _), Exp([PauliZ], 1.7, _), 1);
            AssertOperationsEqualReferenced(Exp([PauliZ], 1.7, _), Exp([PauliZ], 1.7, _), 1);
        }
    }

    operation CurryTest() : () {
        body {
            let curried = CurryOp(Exp([PauliZ], _, _));
            AssertOperationsEqualInPlace(curried(1.7), Exp([PauliZ], 1.7, _), 1);
            AssertOperationsEqualReferenced(curried(1.7), Exp([PauliZ], 1.7, _), 1);
        }
    }

    operation BindTest() : () {
        body {
            let bound = Bind([H; X; H]);
            AssertOperationsEqualReferenced(ApplyToEach(bound, _), ApplyToEachA(Z, _), 3);
        }
    }

    operation BindATest() : () {
        body {
            let bound = BindA([T; T]);
            AssertOperationsEqualReferenced(ApplyToEach(bound, _), ApplyToEachA(S, _), 3);
            AssertOperationsEqualReferenced(ApplyToEach((Adjoint bound), _), ApplyToEachA((Adjoint S), _), 3);
        }
    }

    operation BindCTestHelper0(op: (Qubit => () : Controlled), qubits: Qubit[]) : () {
        body {
            (Controlled op)([qubits[0]], qubits[1]);
        }
    }
    operation BindCTestHelper1(op: (Qubit => () : Adjoint, Controlled), qubits: Qubit[]) : () {
        body {
            (Controlled op)([qubits[0]], qubits[1]);
        }
        adjoint auto
    }

    operation BindCTest() : () {
        body {
            let bound = BindC([T; T]);

            AssertOperationsEqualReferenced(ApplyToEach(bound, _), ApplyToEachA(S, _), 3);

            let op = BindCTestHelper0(bound, _);
            let target = BindCTestHelper1(S, _);
            AssertOperationsEqualReferenced(op, target, 6);
        }
    }

    operation BindCATest() : () {
        body {
            let bound = BindCA([T; T]);

            AssertOperationsEqualReferenced(ApplyToEach(bound, _), ApplyToEachA(S, _), 3);
            AssertOperationsEqualReferenced(ApplyToEach((Adjoint bound), _), ApplyToEachA((Adjoint S), _), 3);

            let op = BindCTestHelper0(Adjoint bound, _);
            let target = BindCTestHelper1(Adjoint S, _);
            AssertOperationsEqualReferenced(op, target, 4);
        }
    }

    operation OperationPowTest() : () {
        body {
            AssertOperationsEqualReferenced(ApplyToEach(OperationPow(H, 2), _), NoOp, 3);
            AssertOperationsEqualReferenced(ApplyToEach(OperationPow(Z, 2), _), NoOp, 3);
            AssertOperationsEqualReferenced(ApplyToEach(OperationPow(S, 4), _), NoOp, 3);
            AssertOperationsEqualReferenced(ApplyToEach(OperationPow(T, 8), _), NoOp, 3);
        }
    }

    operation ApplyToSubregisterTest() : () {
        body {
            let bigOp = ApplyPauli([PauliI; PauliX; PauliY; PauliZ; PauliI], _);
            let smallOp = ApplyPauli([PauliX; PauliY; PauliZ], _);

            AssertOperationsEqualReferenced(ApplyToSubregister(smallOp, [1; 2; 3], _), bigOp, 5);
            AssertOperationsEqualReferenced(RestrictToSubregister(smallOp, [1; 2; 3]), bigOp, 5);

            AssertOperationsEqualReferenced(ApplyToSubregisterC(smallOp, [1; 2; 3], _), bigOp, 5);
            AssertOperationsEqualReferenced(RestrictToSubregisterC(smallOp, [1; 2; 3]), bigOp, 5);

            AssertOperationsEqualReferenced(ApplyToSubregisterA(smallOp, [1; 2; 3], _), bigOp, 5);
            AssertOperationsEqualReferenced(RestrictToSubregisterA(smallOp, [1; 2; 3]), bigOp, 5);

            AssertOperationsEqualReferenced(ApplyToSubregisterCA(smallOp, [1; 2; 3], _), bigOp, 5);
            AssertOperationsEqualReferenced(RestrictToSubregisterCA(smallOp, [1; 2; 3]), bigOp, 5);
        }
    }

    operation CControlledExpected(op : (Qubit => () : Adjoint, Controlled), target : Qubit[]) : () {
        body {
            op(target[0]);
            op(target[2]);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    operation CControlledActual(op : (Qubit => ()), target : Qubit[]) : () {
        body {
            ApplyToEach(CControlled(op), Zip([true; false; true], target));   
        }
    }

    operation CControlledActualC(op : (Qubit => () : Controlled), target : Qubit[]) : () {
        body {
            ApplyToEachC(CControlledC(op), Zip([true; false; true], target));   
        }
        controlled auto
    }

    operation CControlledActualA(op : (Qubit => () : Adjoint), target : Qubit[]) : () {
        body {
            ApplyToEachA(CControlledA(op), Zip([true; false; true], target));   
        }
        adjoint auto
    }

    operation CControlledActualCA(op : (Qubit => () : Adjoint, Controlled), target : Qubit[]) : () {
        body {
            ApplyToEachCA(CControlledCA(op), Zip([true; false; true], target));   
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    operation CControlledTest() : () {
        body {
            AssertOperationsEqualReferenced(CControlledActual(H, _), CControlledExpected(H, _), 3);
            AssertOperationsEqualReferenced(CControlledActual(Z, _), CControlledExpected(Z, _), 3);
            AssertOperationsEqualReferenced(CControlledActual(S, _), CControlledExpected(S, _), 3);
            AssertOperationsEqualReferenced(CControlledActual(T, _), CControlledExpected(T, _), 3);
        }
    }

    operation CControlledTestC() : () {
        body {
            AssertOperationsEqualReferenced(CControlledActualC(H, _), CControlledExpected(H, _), 3);
            AssertOperationsEqualReferenced(CControlledActualC(Z, _), CControlledExpected(Z, _), 3);
            AssertOperationsEqualReferenced(CControlledActualC(S, _), CControlledExpected(S, _), 3);
            AssertOperationsEqualReferenced(CControlledActualC(T, _), CControlledExpected(T, _), 3);
        }
    }

    operation CControlledTestA() : () {
        body {
            AssertOperationsEqualReferenced(CControlledActualA(H, _), CControlledExpected(H, _), 3);
            AssertOperationsEqualReferenced(CControlledActualA(Z, _), CControlledExpected(Z, _), 3);
            AssertOperationsEqualReferenced(CControlledActualA(S, _), CControlledExpected(S, _), 3);
            AssertOperationsEqualReferenced(CControlledActualA(T, _), CControlledExpected(T, _), 3);
        }
    }

    operation CControlledTestCA() : () {
        body {
            AssertOperationsEqualReferenced(CControlledActualCA(H, _), CControlledExpected(H, _), 3);
            AssertOperationsEqualReferenced(CControlledActualCA(Z, _), CControlledExpected(Z, _), 3);
            AssertOperationsEqualReferenced(CControlledActualCA(S, _), CControlledExpected(S, _), 3);
            AssertOperationsEqualReferenced(CControlledActualCA(T, _), CControlledExpected(T, _), 3);
        }
    }

}
