// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;


    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Multi target Controlled Not gates
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Multi target Controlled Not gat gate takes a control qubit
    // with controls and target register |t₁,…,tₙ⟩. On computational basis states it acts as:
    // |c₁⟩⊗|t₁,…,tₙ⟩ ↦ |c₁⟩⊗|t₁⊕c₁,…,tₙ⊕c₁⟩, i.e. the target qubits are flipped
    // if and only if all control qubit is in state |1⟩.

    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// A simple implementation of target Controlled Not gate using CNOT gates
    operation MultiTargetNot (controls : Qubit[], target : Qubit[]) : Unit is Adj {
        EqualityFactI(Length(controls), 1, "control register must have length 1");
        ApplyToEachA(CNOT(Head(controls), _), target);
    }


    /// # Summary
    /// Multi target multi controlled Not implementation using
    /// ApplyMultiControlledCA
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyMultiControlledCA
    operation MultiTargetMultiNot (controls : Qubit[], targets : Qubit[]) : Unit is Adj {

        body (...) {
            let singlyControlledOp = ApplyToPartitionA(MultiTargetNot, 1, _);
            ApplyMultiControlledCA(singlyControlledOp, CCNOTop(CCNOT), controls, targets);
        }

        controlled (extraControls, ...) {
            MultiTargetMultiNot(extraControls + controls, targets);
        }

    }

}
// /////////////////////////////////////////////////////////////////////////////////////////////
// Implementations of Multi target Controlled Not gates not considered here
// /////////////////////////////////////////////////////////////////////////////////////////////

// ● Constant depth remote multi-target CNOT can be implemented
// in 2D nearest neighbor architecture using constant depth
// fanout/un-fanout circuit and ancillary qubits as described in
// [arXiv:1207.6655v2](https://arxiv.org/pdf/1207.6655v2.pdf)

// /////////////////////////////////////////////////////////////////////////////////////////////


