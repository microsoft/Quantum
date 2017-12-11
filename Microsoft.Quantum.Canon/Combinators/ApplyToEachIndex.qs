// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Applies a single-qubit operation to each indexed element in a register.
    ///
    /// # Input
    /// ## singleElementOperation
    /// Operation to apply to each qubit.
    /// ## register
    /// Array of qubits on which to apply the given operation.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the operations acts. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToEach
    /// - Microsoft.Quantum.Canon.ApplyToEachIndexA
    /// - Microsoft.Quantum.Canon.ApplyToEachIndexC
    /// - Microsoft.Quantum.Canon.ApplyToEachIndexCA
    operation ApplyToEachIndex<'T>(singleElementOperation : ((Int, 'T) => ()), register : 'T[])  : ()
    {
        body {
            for (idxQubit in 0..Length(register) - 1) {
                singleElementOperation(idxQubit, register[idxQubit]);
            }
        }
    }

    /// # Summary
    /// Applies a single-qubit operation to each indexed element in a register.
    /// The modifier 'C' indicates that the single-qubit operation is controllable.
    ///
    /// # Input
    /// ## singleElementOperation
    /// Operation to apply to each qubit.
    /// ## register
    /// Array of qubits on which to apply the given operation.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the operations acts. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToEachIndex
    operation ApplyToEachIndexC<'T>(singleElementOperation : ((Int, 'T) => () : Controlled), register : 'T[])  : ()
    {
        body {
            for (idxQubit in 0..Length(register) - 1) {
                singleElementOperation(idxQubit, register[idxQubit]);
            }
        }

        controlled auto
    }

    /// # Summary
    /// Applies a single-qubit operation to each indexed element in a register.
    /// The modifier 'A' indicates that the single-qubit operation is adjointable.
    ///
    /// # Input
    /// ## singleElementOperation
    /// Operation to apply to each qubit.
    /// ## register
    /// Array of qubits on which to apply the given operation.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the operations acts. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToEachIndex
    operation ApplyToEachIndexA<'T>(singleElementOperation : ((Int, 'T) => () : Adjoint), register : 'T[])  : ()
    {
        body {
            for (idxQubit in 0..Length(register) - 1) {
                singleElementOperation(idxQubit, register[idxQubit]);
            }
        }

        adjoint auto
    }

    /// # Summary
    /// Applies a single-qubit operation to each indexed element in a register.
    /// The modifier 'CA' indicates that the single-qubit operation is adjointable
    /// and controllable.
    ///
    /// # Input
    /// ## singleElementOperation
    /// Operation to apply to each qubit.
    /// ## register
    /// Array of qubits on which to apply the given operation.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the operations acts. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToEachIndex
    operation ApplyToEachIndexCA<'T>(singleElementOperation : ((Int, 'T) => () : Adjoint,Controlled), register : 'T[])  : ()
    {
        body {
            for (idxQubit in 0..Length(register) - 1) {
                singleElementOperation(idxQubit, register[idxQubit]);
            }
        }

        adjoint auto
        controlled auto
        controlled adjoint auto
    }

}
