// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Applies an operation to a subregister of a register, with qubits
    /// specified by an array of their indices.
    ///
    /// # Input
    /// ## op
    /// Operation to apply to subregister.
    /// ## idxs
    /// Array of indices, indicating to which qubits the operation will be applied.
    /// ## target
    /// Register on which the operation acts.
    ///
    /// # Remarks
    /// ## Example
    /// Create three qubit state $\frac{1}{\sqrt{2}}\ket{0}\_2(\ket{0}\_1\ket{0}_3+\ket{1}\_1\ket{1}_3)$:
    /// ```qsharp
    ///     using (register = Qubit[3]) {
    ///         ApplyToSubregister(Exp([PauliX;PauliY;],PI() / 4.0,_), [1;3], register);
    ///     }
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToSubregisterA
    /// - Microsoft.Quantum.Canon.ApplyToSubregisterC
    /// - Microsoft.Quantum.Canon.ApplyToSubregisterCA
    operation ApplyToSubregister(op : (Qubit[] => ()), idxs : Int[], target : Qubit[]) : () {
        body {
            let subregister = Subarray(idxs, target);
            op(subregister);
        }
    }

    /// # Summary
    /// Applies an operation to a subregister of a register, with qubits
    /// specified by an array of their indices.
    /// The modifier 'A' indicates that the operation is adjointable.
    ///
    /// # Input
    /// ## op
    /// Operation to apply to subregister.
    /// ## idxs
    /// Array of indices, indicating to which qubits the operation will be applied.
    /// ## target
    /// Register on which the operation acts.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applytosubregister"
    operation ApplyToSubregisterA(op : (Qubit[] => () : Adjoint), idxs : Int[], target : Qubit[]) : () {
        body {
            ApplyToSubregister(op, idxs, target);
        }
        adjoint {
            ApplyToSubregister(Adjoint op, idxs, target);
        }
    }

    /// # Summary
    /// Applies an operation to a subregister of a register, with qubits
    /// specified by an array of their indices.
    /// The modifier 'C' indicates that the operation is controllable.
    ///
    /// # Input
    /// ## op
    /// Operation to apply to subregister.
    /// ## idxs
    /// Array of indices, indicating to which qubits the operation will be applied.
    /// ## target
    /// Register on which the operation acts.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applytosubregister"
    operation ApplyToSubregisterC(op : (Qubit[] => () : Controlled), idxs : Int[], target : Qubit[]) : () {
        body {
            ApplyToSubregister(op, idxs, target);
        }
        controlled (controls) {
            let cop = (Controlled op);
            ApplyToSubregister(cop(controls, _), idxs, target);
        }
    }

    /// # Summary
    /// Applies an operation to a subregister of a register, with qubits
    /// specified by an array of their indices.
    /// The modifier 'CA' indicates that the operation is controllable and adjointable.
    ///
    /// # Input
    /// ## op
    /// Operation to apply to subregister.
    /// ## idxs
    /// Array of indices, indicating to which qubits the operation will be applied.
    /// ## target
    /// Register on which the operation acts.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applytosubregister"
    operation ApplyToSubregisterCA(op : (Qubit[] => () : Controlled, Adjoint), idxs : Int[], target : Qubit[]) : () {
        body {
            ApplyToSubregister(op, idxs, target);
        }
        adjoint {
            ApplyToSubregister(Adjoint op, idxs, target);
        }
        controlled (controls) {
            let cop = (Controlled op);
            ApplyToSubregister(cop(controls, _), idxs, target);
        }
        controlled adjoint (controls) {
            let cop = (Controlled Adjoint op);
            ApplyToSubregister(cop(controls, _), idxs, target);
        }
    }

    /// # Summary
    /// Restricts an operation to an array of indices of a register, i.e., a subregister.
    ///
    /// # Input
    /// ## op
    /// Operation to be restricted to a subregister.
    /// ## idxs
    /// Array of indices, indicating to which qubits the operation will be restricted.
    /// ## target
    /// Register on which the operation acts.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.RestrictToSubregisterA
    /// - Microsoft.Quantum.Canon.RestrictToSubregisterC
    /// - Microsoft.Quantum.Canon.RestrictToSubregisterCA
    function RestrictToSubregister(op : (Qubit[] => ()), idxs : Int[]) : (Qubit[] => ()) {
        return ApplyToSubregister(op, idxs, _);
    }

    /// # Summary
    /// Restricts an operation to an array of indices of a register, i.e., a subregister.
    /// The modifier 'A' indicates that the operation is adjointable.
    ///
    /// # Input
    /// ## op
    /// Operation to be restricted to a subregister.
    /// ## idxs
    /// Array of indices, indicating to which qubits the operation will be restricted.
    /// ## target
    /// Register on which the operation acts.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.RestrictToSubregister
    function RestrictToSubregisterA(op : (Qubit[] => () : Adjoint), idxs : Int[]) : (Qubit[] => () : Adjoint) {
        return ApplyToSubregisterA(op, idxs, _);
    }

    /// # Summary
    /// Restricts an operation to an array of indices of a register, i.e., a subregister.
    /// The modifier 'C' indicates that the operation is controllable.
    ///
    /// # Input
    /// ## op
    /// Operation to be restricted to a subregister.
    /// ## idxs
    /// Array of indices, indicating to which qubits the operation will be restricted.
    /// ## target
    /// Register on which the operation acts.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.RestrictToSubregister
    function RestrictToSubregisterC(op : (Qubit[] => () : Controlled), idxs : Int[]) : (Qubit[] => () : Controlled) {
        return ApplyToSubregisterC(op, idxs, _);
    }

    /// # Summary
    /// Restricts an operation to an array of indices of a register, i.e., a subregister.
    /// The modifier 'CA' indicates that the operation is controllable and adjointable.
    ///
    /// # Input
    /// ## op
    /// Operation to be restricted to a subregister.
    /// ## idxs
    /// Array of indices, indicating to which qubits the operation will be restricted.
    /// ## target
    /// Register on which the operation acts.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.RestrictToSubregister
    function RestrictToSubregisterCA(op : (Qubit[] => () : Adjoint, Controlled), idxs : Int[]) : (Qubit[] => () : Adjoint, Controlled) {
        return ApplyToSubregisterCA(op, idxs, _);
    }

}
