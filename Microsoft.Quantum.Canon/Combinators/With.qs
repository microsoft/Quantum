// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;

    /// # Summary
    /// Given operations implementing operators $U$ and $V$, performs the
    /// operation $UVU^{\dagger}$ on a target. That is, this operation
    /// conjugates $V$ with $U$.
    ///
    /// # Input
    /// ## outerOperation
    /// The operation $U$ that should be used to conjugate $V$. Note that the
    /// outer operation $U$ needs to be adjointable, but does not
    /// need to be controllable.
    /// ## innerOperation
    /// The operation $V$ being conjugated.
    /// ## target
    /// The input to be provided to the outer and inner operations.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the inner and outer operations act.
    ///
    /// # Remarks
    /// The outer operation is always assumed to be adjointable, but does not
    /// need to be controllable in order for the combined operation to be
    /// controllable.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.WithC
    /// - Microsoft.Quantum.Canon.WithA
    /// - Microsoft.Quantum.Canon.WithCA
    operation With<'T>(outerOperation : ('T => ():Adjoint), innerOperation : ('T => ()), target : 'T)  : ()
    {
        body {
            outerOperation(target);
            innerOperation(target);
            (Adjoint(outerOperation))(target);
        }
    }

    /// # Summary
    /// Given operations implementing operators $U$ and $V$, performs the
    /// operation $UVU^{\dagger}$ on a target. That is, this operation
    /// conjugates $V$ with $U$.
    /// The modifier 'A' indicates that the inner operation is adjointable.
    ///
    /// # Input
    /// ## outerOperation
    /// The operation $U$ that should be used to conjugate $V$. Note that the
    /// outer operation $U$ needs to be adjointable, but does not
    /// need to be controllable.
    /// ## innerOperation
    /// The operation $V$ being conjugated.
    /// ## target
    /// The input to be provided to the outer and inner operations.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the inner and outer operations act.
    ///
    /// # Remarks
    /// The outer operation is always assumed to be adjointable, but does not
    /// need to be controllable in order for the combined operation to be
    /// controllable.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.With
    operation WithA<'T>(outerOperation : ('T => ():Adjoint), innerOperation : ('T => ():Adjoint), target : 'T)  : ()
    {
        body {
            outerOperation(target);
            innerOperation(target);
            (Adjoint(outerOperation))(target);
        }

        adjoint auto
    }

    /// # Summary
    /// Given operations implementing operators $U$ and $V$, performs the
    /// operation $UVU^{\dagger}$ on a target. That is, this operation
    /// conjugates $V$ with $U$.
    /// The modifier 'C' indicates that the inner operation is controllable.
    ///
    /// # Input
    /// ## outerOperation
    /// The operation $U$ that should be used to conjugate $V$. Note that the
    /// outer operation $U$ needs to be adjointable, but does not
    /// need to be controllable.
    /// ## innerOperation
    /// The operation $V$ being conjugated.
    /// ## target
    /// The input to be provided to the outer and inner operations.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the inner and outer operations act.
    ///
    /// # Remarks
    /// The outer operation is always assumed to be adjointable, but does not
    /// need to be controllable in order for the combined operation to be
    /// controllable.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.With
    operation WithC<'T>(outerOperation : ('T => ():Adjoint), innerOperation : ('T => ():Controlled), target : 'T)  : ()
    {
        body {
            outerOperation(target);
            innerOperation(target);
            (Adjoint(outerOperation))(target);
        }

        controlled(controlRegister) {
            outerOperation(target);
            (Controlled(innerOperation))(controlRegister, target);
            (Adjoint(outerOperation))(target);
        }
    }

     /// # Summary
    /// Given operations implementing operators $U$ and $V$, performs the
    /// operation $UVU^{\dagger}$ on a target. That is, this operation
    /// conjugates $V$ with $U$.
    /// The modifier 'CA' indicates that the inner operation is controllable
    /// and adjointable.
    ///
    /// # Input
    /// ## outerOperation
    /// The operation $U$ that should be used to conjugate $V$. Note that the
    /// outer operation $U$ needs to be adjointable, but does not
    /// need to be controllable.
    /// ## innerOperation
    /// The operation $V$ being conjugated.
    /// ## target
    /// The input to be provided to the outer and inner operations.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the inner and outer operations act.
    ///
    /// # Remarks
    /// The outer operation is always assumed to be adjointable, but does not
    /// need to be controllable in order for the combined operation to be
    /// controllable.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.With
    operation WithCA<'T>(outerOperation : ('T => ():Adjoint), innerOperation : ('T => ():Adjoint,Controlled), target : 'T)  : ()
    {
        body {
            outerOperation(target);
            innerOperation(target);
            (Adjoint(outerOperation))(target);
        }

        adjoint auto
        controlled(controlRegister) {
            outerOperation(target);
            (Controlled(innerOperation))(controlRegister, target);
            (Adjoint(outerOperation))(target);
        }
        controlled adjoint auto
    }

}