// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Applies a single-qubit operation to each element in a register.
    /// The modifier 'CA' indicates that the single-qubit operation is controllable
    /// and adjointable.
    ///
    /// # Input
    /// ## singleElementOperation
    /// Operation to apply to each qubit.
    /// ## register
    /// Array of qubits on which to apply the given operation.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which the operation acts.
    ///
    /// # Remarks
    /// ## Example
    /// Prepare a three-qubit $\ket{+}$ state:
    /// ```Q#
    /// using (register = Qubit[3]) {
    ///     ApplyToEach(H, register);
    /// }
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToEach
   operation ApplyToEachCA<'T>(singleElementOperation : ('T => () : Adjoint, Controlled), register : 'T[])  : ()
    {
        body {
            for (idxQubit in 0..(Length(register) - 1)) {
                singleElementOperation(register[idxQubit]);
            }
        }

        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Applies a single-qubit operation to each element in a register.
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
    /// The target on which the operation acts.
    ///
    /// # Remarks
    /// ## Example
    /// Prepare a three-qubit $\ket{+}$ state:
    /// ```Q#
    /// using (register = Qubit[3]) {
    ///     ApplyToEach(H, register);
    /// }
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToEach
    operation ApplyToEachA<'T>(singleElementOperation : ('T => ():Adjoint), register : 'T[])  : ()
    {
        body {
            for (idxQubit in 0..(Length(register) - 1)) {
                singleElementOperation(register[idxQubit]);
            }
        }

        adjoint auto
    }

    /// # Summary
    /// Applies a single-qubit operation to each element in a register.
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
    /// The target on which the operation acts.
    ///
    /// # Remarks
    /// ## Example
    /// Prepare a three-qubit $\ket{+}$ state:
    /// ```Q#
    /// using (register = Qubit[3]) {
    ///     ApplyToEach(H, register);
    /// }
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToEach
    operation ApplyToEachC<'T>(singleElementOperation : ('T => ():Controlled), register : 'T[])  : ()
    {
        body {
            for (idxQubit in 0..(Length(register) - 1)) {
                singleElementOperation(register[idxQubit]);
            }
        }

        controlled auto
    }

    /// # Summary
    /// Applies a single-qubit operation to each element in a register.
    ///
    /// # Input
    /// ## singleElementOperation
    /// Operation to apply to each qubit.
    /// ## register
    /// Array of qubits on which to apply the given operation.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which the operation acts.
    ///
    /// # Remarks
    /// ## Example
    /// Prepare a three-qubit $\ket{+}$ state:
    /// ```Q#
    /// using (register = Qubit[3]) {
    ///     ApplyToEach(H, register);
    /// }
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToEachC
    /// - Microsoft.Quantum.Canon.ApplyToEachA
    /// - Microsoft.Quantum.Canon.ApplyToEachCA
    operation ApplyToEach<'T>(singleElementOperation : ('T => ()), register : 'T[])  : ()
    {
        body {
            for (idxQubit in 0..(Length(register) - 1)) {
                singleElementOperation(register[idxQubit]);
            }
        }
    }

}
