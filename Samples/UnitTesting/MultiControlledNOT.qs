// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Multiply Controlled Not gates
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //
    // This file contains different implementations multiply controlled Not gate, 
    // also known as multiply controlled Pauli X gate and closely related to 
    // Multiply Controlled Toffoli gate
    // Multiply Controlled Not gate takes a qubit register |c₁,…,cₙ⟩ 
    // with controls and target Qubit |t₁⟩. On computational basis states it acts as: 
    // |c₁,…,cₙ⟩⊗|t₁⟩ ↦ |c₁,…,cₙ⟩⊗|t₁⊕(c₁∧…∧cₙ)⟩, i.e. the target qubit t is flipped
    // if and only if all control qubits are in state |1⟩ .
    // The gate is also equivalent to Controlled(Microsoft.Quantum.Primitive.X)
    //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary 
    /// Implements Multiply Controlled Not gate using Microsoft.Quantum.Canon
    /// library combinator
    ///
    /// # Input 
    /// ## controls
    /// Quantum register which holds the control qubits 
    /// ## target
    /// Qubit which is the target of the multiply controlled NOT. 
    ///
    /// # See Also
    /// - @"Microsoft.Quantum.Canon.ApplyMultiControlledCA"
    operation MultiControlledXClean ( controls : Qubit[] , target : Qubit ) : () {
        body {
            let numControls = Length(controls);
            if( numControls == 0 ) {
                X(target);
            } elif( numControls == 1 ) {
                CNOT(Head(controls),target);
            } elif( numControls == 2 ) {
                CCNOT(controls[1],controls[0],target);
            } else {
                let multiNot = 
                    ApplyMultiControlledCA(
                        ApplyToFirstThreeQubitsCA(CCNOT, _), CCNOTop(CCNOT), _, _ );
                multiNot(Rest(controls),[Head(controls);target]);
            }
        }
        adjoint auto 
        controlled( extraControls ) {
            MultiControlledXClean( extraControls + controls, target );
        }
        controlled adjoint auto
    }

    /// # Summary
    /// Multiply controlled NOT gate using dirty ancillas, according to Barenco et al 
    ///
    /// # Input 
    /// ## controls
    /// Quantum register which holds the control qubits 
    /// ## target
    /// Qubit which is the target of the multiply controlled NOT.
    ///
    /// # References
    /// - [ *A. Barenco, Ch.H. Bennett, R. Cleve, D.P. DiVincenzo, N.Margolus, P.Shor,
    ///     T.Sleator, J.A. Smolin, H. Weinfurter* 
    ///     Phys. Rev. A 52, 3457 (1995)](http://doi.org/10.1103/PhysRevA.52.3457)
    ///
    /// # See Also
    /// - For the circuit diagram see the figure on 
    ///   [Page 19 of arXiv:quant-ph/9503016](https://arxiv.org/pdf/quant-ph/9503016v1.pdf#page=19)
    /// - File MultiControlledXBorrow.png in the same folder as this file shows
    ///   the relation between the function implementation and circuit.
    /// 
    /// # Remarks
    /// The circuit uses (Length(controls)-2) dirty ancillas. These are used as scratch 
    /// space and are returned in the same state as when they were borrowed.
    operation MultiControlledXBorrow ( controls : Qubit[] , target : Qubit ) : () {
        body {
            let numberOfControls = Length(controls);
            if( numberOfControls == 0 ) {
                X(target);
            } elif( numberOfControls == 1 ) {
                CNOT(Head(controls),target);
            } elif( numberOfControls == 2 ) {
                CCNOT(controls[1],controls[0],target);
            } else {
                let numberOfDirtyQubits = numberOfControls - 2;
                borrowing( dirtyQubits = Qubit[ numberOfDirtyQubits ] ) {

                    let allQubits = [ target ] + dirtyQubits + controls;
                    let lastDirtyQubit = numberOfDirtyQubits;
                    let totalNumberOfQubits = Length(allQubits);

                    let outerOperation1 = 
                        CCNOTByIndexLadder(
                            numberOfDirtyQubits + 1, 1, 0, numberOfDirtyQubits , _ );
                    
                    let innerOperation = 
                        CCNOTByIndex(
                            totalNumberOfQubits - 1, totalNumberOfQubits - 2, lastDirtyQubit, _ );
                    
                    WithA(outerOperation1, innerOperation, allQubits);
                    
                    let outerOperation2 = 
                        CCNOTByIndexLadder(
                            numberOfDirtyQubits + 2, 2, 1, numberOfDirtyQubits - 1 , _ );
                    
                    WithA(outerOperation2, innerOperation, allQubits);
                }
            }
        }
        adjoint auto
        controlled( extraControls ) {
            MultiControlledXBorrow( extraControls + controls, target );
        }
        controlled adjoint auto
    }

    /// # Summary
    /// Applies CCNOT to the qubits in target given by their indexes 
    operation CCNOTByIndex
            ( control1Index : Int,
              control2Index : Int, 
              targetIndex : Int, 
              target : Qubit[] ) : () {
        body {
            CCNOT(target[control1Index],target[control2Index],target[targetIndex]);
        }
        adjoint auto
    }

    /// # Summary
    /// Repeatedly applies CCNOT to the qubits in target given by their indexes 
    /// Start with applying 
    operation CCNOTByIndexLadder (
              control1Index : Int,
              control2Index : Int, 
              targetIndex : Int, 
              count : Int,
              target : Qubit[] ) : () {
        body {
            for( i in 0 .. count - 1 ) {
                CCNOTByIndex(i + control1Index, i + control2Index, targetIndex + i, target);
            }        
        }
        adjoint auto
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Implementations of multiply controlled not gates not illustrated here
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // 
    // ● The implementations that use all dirty or all clean ancilla are two extreme cases
    //   It is possible to interpolate between them and explore gate count / number of extra
    //   ancilla trade-offs 
    //
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
