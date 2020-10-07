// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;


    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Multiply Controlled Not gates
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // This file contains different implementations multiply controlled Not gate,
    // also known as multiply controlled Pauli X gate and closely related to
    // Multiply Controlled Toffoli gate
    // Multiply Controlled Not gate takes a qubit register |c₁,…,cₙ⟩
    // with controls and target Qubit |t₁⟩. On computational basis states it acts as:
    // |c₁,…,cₙ⟩⊗|t₁⟩ ↦ |c₁,…,cₙ⟩⊗|t₁⊕(c₁∧…∧cₙ)⟩, i.e. the target qubit t is flipped
    // if and only if all control qubits are in state |1⟩ .
    // The gate is also equivalent to Controlled(Microsoft.Quantum.Intrinsic.X)

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
    operation ApplyMultiControlledXByUsing (controls : Qubit[], target : Qubit) : Unit {
        body (...) {
            let numControls = Length(controls);

            if (numControls == 0) {
                X(target);
            }
            elif (numControls == 1) {
                CNOT(Head(controls), target);
            }
            elif (numControls == 2) {
                CCNOT(controls[1], controls[0], target);
            }
            else {
                // let multiNot = ApplyMultiControlledCA(ApplyToFirstThreeQubitsCA(CCNOT, _), CCNOTop(CCNOT), _, _);
                // multiNot(Rest(controls), [Head(controls), target]);
                ApplyMultiControlledCA(
                    ApplyToFirstThreeQubitsCA(CCNOT, _), CCNOTop(CCNOT),
                    Rest(controls),
                    [Head(controls), target]
                );
            }
        }

        adjoint invert;

        controlled (extraControls, ...) {
            ApplyMultiControlledXByUsing(extraControls + controls, target);
        }

        controlled adjoint invert;
    }


    /// # Summary
    /// Multiply controlled NOT gate using dirty qubits, according to Barenco et al
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
    /// The circuit uses (Length(controls)-2) dirty qubits. These are used as scratch
    /// space and are returned in the same state as when they were borrowed.
    operation ApplyMultiControlledXByBorrowing(controls : Qubit[], target : Qubit) : Unit {

        body (...) {
            let numberOfControls = Length(controls);

            if (numberOfControls == 0) {
                X(target);
            }
            elif (numberOfControls == 1) {
                CNOT(Head(controls), target);
            }
            elif (numberOfControls == 2) {
                CCNOT(controls[1], controls[0], target);
            }
            else {
                let numberOfDirtyQubits = numberOfControls - 2;

                borrowing (dirtyQubits = Qubit[numberOfDirtyQubits]) {
                    within {
                        ApplyToEachCA(
                            CCNOT,
                            Zipped3(
                                controls[0..Length(controls) - 2],
                                dirtyQubits,
                                [target] + Most(dirtyQubits)
                            )
                        );
                    } apply {
                        CCNOT(controls[Length(controls) - 1], controls[Length(controls) - 2], Tail(dirtyQubits));
                    }

                    within {
                        ApplyToEachCA(
                            CCNOT,
                            Zipped3(
                                Rest(controls),
                                Rest(dirtyQubits),
                                Most(dirtyQubits)
                            )
                        );
                    } apply {
                        CCNOT(controls[Length(controls) - 1], controls[Length(controls) - 2], Tail(dirtyQubits));
                    }
                }
            }
        }

        adjoint invert;

        controlled (extraControls, ...) {
            ApplyMultiControlledXByBorrowing(extraControls + controls, target);
        }

        controlled adjoint invert;
    }

}
// /////////////////////////////////////////////////////////////////////////////////////////////
// Implementations of multiply controlled not gates not illustrated here
// /////////////////////////////////////////////////////////////////////////////////////////////

// ● The implementations that use all dirty or all clean auxiliary qubits are two extreme cases
// It is possible to interpolate between them and explore gate count / number of extra
// auxiliary qubit trade-offs

// /////////////////////////////////////////////////////////////////////////////////////////////
