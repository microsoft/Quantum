// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Canon {

	/// # Summary
	/// Performs the identity operation (no-op) on a register of qubits.
	operation NoOp(qubits: Qubit[]) : () {
		body {}
		adjoint auto
		controlled auto
		adjoint controlled auto
	}

	/// # Summary
	/// Performs the identity operation (no-op) on two registers of qubits.
	operation NoOp2(qubitsA: Qubit[], qubitsB: Qubit[]) : (){
		body {}
		adjoint auto
		controlled auto
		adjoint controlled auto
	}

	/// # Summary
	/// Ignores the output of an operation or function.
	///
	/// # Input
	/// ## value
	/// A value to be ignored.
	function Ignore<'T>(value : 'T) : () {
		return ();
	}

}
