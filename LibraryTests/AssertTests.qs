// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {
	open Microsoft.Quantum.Primitive;
	open Microsoft.Quantum.Canon;

	// This file contains very simple tests that should trivially pass
	// with the intent of testing the assert and testing harness mechanisms themselves.

	operation EmptyTest() : () {
		body {

		}
	}

	operation PreparationTest () : () {
		body {
		   using (qubits = Qubit[1]) {
		       AssertProb([PauliZ], [qubits[0]], Zero, 1.0, "Freshly prepared qubit was not in |0〉 state.", 1e-10);
		   }
		}
	}

	operation OperationTestShouldFail() : () {
		body {
			fail "OK";
		}
	}

	function FunctionTestShouldFail() : () {
		fail "OK";
	}

	function AssertEqualTestShouldFail() : () {
		AssertAlmostEqual(1.0, 0.0);
	}

    function AssertBoolArrayEqualTestShouldFail() : () {
        AssertBoolArrayEqual([true; false], [false; true], "OK");
    }

    function AssertBoolEqualTestShouldFail() : () {
        AssertBoolEqual(true, false, "OK");
    }

    function AssertIntEqualTestShouldFail() : () {
        AssertIntEqual(12, 42, "OK");
    }

	/// # Summary
	/// Tests whether common builtin operations are self adjoint.
	/// These tests are already performed in Solid itself, such that
	/// this operation tests whether we can reproduce that using our
	/// operation equality assertions.
	operation SelfAdjointOperationsTest() : () {
		body {
			let ops = [I; X; Y; Z; H];
			for (idxOp in 0..Length(ops) - 1) {
				AssertOperationsEqualReferenced(ApplyToEach(ops[idxOp], _), ApplyToEachA(ops[idxOp], _), 3);
			}
		}
	}

	/// # Summary
	/// Performs the same test as SelfAdjointOperationsTest,
	/// but using Bind to gather the self-adjoint operations.
	///
	/// # Remarks
	/// Marked as ex-fail due to known issues with Bind.
	operation BindSelfAdjointOperationsTestExFail() : () {
		body {
			let ops = [I; X; Y; Z; H];
			for (idxOp in 0..Length(ops) - 1) {
				let arr = [ops[idxOp]; Adjoint ops[idxOp]];
				let bound = BindCA(arr);
				AssertOperationsEqualReferenced(ApplyToEachCA(BindCA(arr), _), ApplyToEachA(I, _), 3);
			}
		}
	}
}
