// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    
    // # Overview 
    // Variants of the operation that applies given one, two and three qubit 
    // operation to the first one, two and three qubits of a register

    /// # Summary
    /// Applies operation op to the first qubit in the register.
    /// # Input
    /// ## op
    /// An operation to be applied to the first qubit
    /// ## register 
    /// Qubit array to the first qubit of which the operation is applied
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applytofirstqubita"
    /// - @"microsoft.quantum.canon.applytofirstqubitc"
    /// - @"microsoft.quantum.canon.applytofirstqubitca"
    operation ApplyToFirstQubit( op : (Qubit => ()), register : Qubit[] ) : () {
        body {
            if (Length(register) == 0) {
                fail "Must have at least one qubit to act on.";
            }
            op(register[0]);
        }
    }

    /// # Summary
    /// Applies operation op to the first qubit in the register.
    /// The modifier 'A' indicates that the operation is adjointable. 
    /// # Input
    /// ## op
    /// An operation to be applied to the first qubit
    /// ## register 
    /// Qubit array to the first qubit of which the operation is applied
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applytofirstqubit"
    operation ApplyToFirstQubitA( op : (Qubit => () : Adjoint), register : Qubit[] ) : () {
        body {
            if (Length(register) == 0) {
                fail "Must have at least one qubit to act on.";
            }
            op(register[0]);
        }
        adjoint auto
    }

    /// # Summary
    /// Applies operation op to the first qubit in the register.
    /// The modifier 'C' indicates that the operation is controllable.
    /// # Input
    /// ## op
    /// An operation to be applied to the first qubit
    /// ## register 
    /// Qubit array to the first qubit of which the operation is applied
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applytofirstqubit"
    operation ApplyToFirstQubitC( op : (Qubit => () : Controlled), register : Qubit[] ) : () {
        body {
            if (Length(register) == 0) {
                fail "Must have at least one qubit to act on.";
            }
            op(register[0]);
        }
        controlled auto
    }

    /// # Summary
    /// Applies operation op to the first qubit in the register.
    /// The modifier 'CA' indicates that the operation is controllable and adjointable. 
    /// # Input
    /// ## op
    /// An operation to be applied to the first qubit
    /// ## register 
    /// Qubit array to the first qubit of which the operation is applied
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applytofirstqubit"
    operation ApplyToFirstQubitCA( op : (Qubit => () : Adjoint, Controlled), register : Qubit[] ) : () {
        body {
            if (Length(register) == 0) {
                fail "Must have at least one qubit to act on.";
            }
            op(register[0]);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Applies operation `op` to the first two qubits in the register.
    ///
    /// # Input
    /// ## op
    /// An operation to be applied to the first two qubits
    /// ## register
    /// Qubit array to the first two qubits of which the operation is applied.
    ///
    /// # Remarks
    /// This is equivalent to:
    /// ```qsharp
    /// op(register[0], register[1]);
    /// ```
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applytofirsttwoqubitsa"
    /// - @"microsoft.quantum.canon.applytofirsttwoqubitsc"
    /// - @"microsoft.quantum.canon.applytofirsttwoqubitsca"
    operation ApplyToFirstTwoQubits( op : ((Qubit,Qubit) => ()), register : Qubit[] ) : () {
        body {
            if (Length(register) < 2) {
                fail "Must have at least two qubits to act on.";
            }
            op(register[0],register[1]);
        }
    }

    /// # Summary
    /// Applies operation `op` to the first two qubits in the register.
    /// The modifier 'A' indicates that the operation is adjointable.
    ///
    /// # Input
    /// ## op
    /// An operation to be applied to the first two qubits
    /// ## register
    /// Qubit array to the first two qubits of which the operation is applied.
    ///
    /// # Remarks
    /// This is equivalent to:
    /// ```qsharp
    /// op(register[0], register[1]);
    /// ```
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applytofirsttwoqubits"
    operation ApplyToFirstTwoQubitsA( op : ((Qubit,Qubit) => () : Adjoint ), register : Qubit[] ) : () {
        body {
            if (Length(register) < 2) {
                fail "Must have at least two qubits to act on.";
            }
            op(register[0],register[1]);
        }
        adjoint auto
    }

    
    /// # Summary
    /// Applies operation `op` to the first two qubits in the register.
    /// The modifier 'C' indicates that the operation is controllable.
    ///
    /// # Input
    /// ## op
    /// An operation to be applied to the first two qubits
    /// ## register
    /// Qubit array to the first two qubits of which the operation is applied.
    ///
    /// # Remarks
    /// This is equivalent to:
    /// ```qsharp
    /// op(register[0], register[1]);
    /// ```
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applytofirsttwoqubits"
    operation ApplyToFirstTwoQubitsC( op : ((Qubit,Qubit) => () : Controlled ), register : Qubit[] ) : () {
        body {
            if (Length(register) < 2) {
                fail "Must have at least two qubits to act on.";
            }
            op(register[0],register[1]);
        }
        controlled auto
    }
    
    /// # Summary
    /// Applies operation `op` to the first two qubits in the register.
    /// The modifier 'CA' indicates that the operation is controllable and adjointable. 
    ///
    /// # Input
    /// ## op
    /// An operation to be applied to the first two qubits
    /// ## register
    /// Qubit array to the first two qubits of which the operation is applied.
    ///
    /// # Remarks
    /// This is equivalent to:
    /// ```qsharp
    /// op(register[0], register[1]);
    /// ```
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applytofirsttwoqubits"
    operation ApplyToFirstTwoQubitsCA( op : ((Qubit,Qubit) => () : Adjoint, Controlled ), register : Qubit[] ) : () {
        body {
            if (Length(register) < 2) {
                fail "Must have at least two qubits to act on.";
            }
            op(register[0],register[1]);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Applies operation `op` to the first three qubits in the register.
    /// # Input
    /// ## op
    /// An operation to be applied to the first three qubits
    /// ## register 
    /// Qubit array to the first three qubits of which the operation is applied.
    ///
    /// # Remarks
    /// This is equivalent to:
    /// ```qsharp
    /// op(register[0], register[1], register[2]);
    /// ```
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToFirstThreeQubitsC
    /// - Microsoft.Quantum.Canon.ApplyToFirstThreeQubitsA
    /// - Microsoft.Quantum.Canon.ApplyToFirstThreeQubitsCA
    operation ApplyToFirstThreeQubits( op : ((Qubit,Qubit,Qubit) => ()), register : Qubit[] ) : () {
        body {
            if (Length(register) < 3) {
                fail "Must have at least three qubits to act on.";
            }
            op(register[0],register[1],register[2]);
        }
    }

    /// # Summary
    /// Applies operation `op` to the first three qubits in the register.
    /// The modifier 'A' indicates that the operation is adjointable. 
    /// # Input
    /// ## op
    /// An operation to be applied to the first three qubits
    /// ## register 
    /// Qubit array to the first three qubits of which the operation is applied.
    ///
    /// # Remarks
    /// This is equivalent to:
    /// ```qsharp
    /// op(register[0], register[1], register[2]);
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToFirstThreeQubits
    operation ApplyToFirstThreeQubitsA( op : ((Qubit,Qubit,Qubit) => () : Adjoint), register : Qubit[] ) : () {
        body {
            if (Length(register) < 3) {
                fail "Must have at least three qubits to act on.";
            }
            op(register[0],register[1],register[2]);
        }
        adjoint auto
    }

    /// # Summary
    /// Applies operation `op` to the first three qubits in the register.
    /// The modifier 'C' indicates that the operation is controllable. 
    /// # Input
    /// ## op
    /// An operation to be applied to the first three qubits
    /// ## register 
    /// Qubit array to the first three qubits of which the operation is applied.
    ///
    /// # Remarks
    /// This is equivalent to:
    /// ```qsharp
    /// op(register[0], register[1], register[2]);
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToFirstThreeQubits
    operation ApplyToFirstThreeQubitsC( op : ((Qubit,Qubit,Qubit) => () : Controlled), register : Qubit[] ) : () {
        body {
            if (Length(register) < 3) {
                fail "Must have at least three qubits to act on.";
            }
            op(register[0],register[1],register[2]);
        }
        controlled auto
    }

    /// # Summary
    /// Applies operation `op` to the first three qubits in the register.
    /// The modifier 'CA' indicates that the operation is controllable and adjointable. 
    /// # Input
    /// ## op
    /// An operation to be applied to the first three qubits
    /// ## register 
    /// Qubit array to the first three qubits of which the operation is applied.
    ///
    /// # Remarks
    /// This is equivalent to:
    /// ```qsharp
    /// op(register[0], register[1], register[2]);
    /// ```
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyToFirstThreeQubits
    operation ApplyToFirstThreeQubitsCA( op : ((Qubit,Qubit,Qubit) => () : Adjoint, Controlled), register : Qubit[] ) : () {
        body {
            if (Length(register) < 3) {
                fail "Must have at least three qubits to act on.";
            }
            op(register[0],register[1],register[2]);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }
}
