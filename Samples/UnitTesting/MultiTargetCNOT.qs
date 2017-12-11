// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Multi target Controlled Not gates
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Multi target Controlled Not gat gate takes a control qubit  
    // with controls and target register |t₁,…,tₙ⟩. On computational basis states it acts as: 
    // |c₁⟩⊗|t₁,…,tₙ⟩ ↦ |c₁⟩⊗|t₁⊕c₁,…,tₙ⊕c₁⟩, i.e. the target qubits are flipped
    // if and only if all control qubit is in state |1⟩. 
    // 
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary 
    /// A simple implementation of target Controlled Not gate using CNOT gates
    operation MultiTargetNot ( controls : Qubit[] , target : Qubit[] ) : () {
        body {
            AssertBoolEqual(Length(controls) == 1, true, "control register must have length 1");
            for( i in 0 .. Length(target) - 1 ) {
                CNOT(controls[0],target[i]);
            }
        }
        adjoint auto
    }

    /// # Summary 
    /// Multi target multi controlled Not implementation using 
    /// ApplyMultiControlledCA
    /// # See Also
    /// - @"Microsoft.Quantum.Canon.ApplyMultiControlledCA"
    operation MultiTargetMultiNot ( controls : Qubit[] , targets : Qubit[] ) : () {
        body {
            let singlyControlledOp = ApplyToPartitionA(MultiTargetNot,1, _);
            ApplyMultiControlledCA(singlyControlledOp, CCNOTop(CCNOT), controls, targets);
        }
        adjoint auto 
        controlled( extraControls ) {
            MultiTargetMultiNot( extraControls + controls, targets );
        }
        controlled adjoint auto
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Implementations of Multi target Controlled Not gates not considered here
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // 
    // ● Constant depth remote multi-target CNOT can be implemented 
    //   in 2D nearest neighbor architecture using constant depth 
    //   fanout/un-fanout circuit and ancillary qubits as described in 
    //   [arXiv:1207.6655v2](https://arxiv.org/pdf/1207.6655v2.pdf)
    // 
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
