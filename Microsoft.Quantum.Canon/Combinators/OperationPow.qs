// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    operation OperationPowImpl<'T>(oracle : ('T => ()), power : Int, target : 'T)  : ()
    {
        body {
            for (idxApplication in 0..power - 1) {
                oracle(target);
            }
        }
    }

    operation OperationPowImplC<'T>(oracle : ('T => () : Controlled), power : Int, target : 'T)  : ()
    {
        body {
            for (idxApplication in 0..power - 1) {
                oracle(target);
            }
        }

        controlled auto
    }

    operation OperationPowImplA<'T>(oracle : ('T => () : Adjoint), power : Int, target : 'T)  : ()
    {
        body {
            for (idxApplication in 0..power - 1) {
                oracle(target);
            }
        }

        adjoint auto
    }

    operation OperationPowImplCA<'T>(oracle : ('T => () : Controlled, Adjoint), power : Int, target : 'T)  : ()
    {
        body {
            for (idxApplication in 0..power - 1) {
                oracle(target);
            }
        }

        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Given an operation representing a gate $U$, returns a new operation
    /// $U^m$ for a power $m$.
    ///
    /// # Input
    /// ## oracle
    /// An operation $U$ representing the gate to be repeated.
    /// ## power
    /// The number of times that $U$ is to be repeated.
    ///
    /// # Output
    /// A new operation representing $U^m$, where $m = \texttt{power}$.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The type of the operation to be powered. 
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.operationpowc"
    /// - @"microsoft.quantum.canon.operationpowa"
    /// - @"microsoft.quantum.canon.operationpowca"
    function OperationPow<'T>(oracle : ('T => ()), power : Int)  : ('T => ())
    {
        return OperationPowImpl(oracle, power, _);
    }

    /// # Summary
    /// Given an operation representing a gate $U$, returns a new operation
    /// $U^m$ for a power $m$.
    /// The modifier 'C' indicates that the operation is controllable.
    ///
    /// # Input
    /// ## oracle
    /// An operation $U$ representing the gate to be repeated.
    /// ## power
    /// The number of times that $U$ is to be repeated.
    ///
    /// # Output
    /// A new operation representing $U^m$, where $m = \texttt{power}$.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The type of the operation to be powered. 
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.operationpow"
    function OperationPowC<'T>(oracle : ('T => () : Controlled), power : Int)  : ('T => () : Controlled)
    {
        return OperationPowImplC(oracle, power, _);
    }

    /// # Summary
    /// Given an operation representing a gate $U$, returns a new operation
    /// $U^m$ for a power $m$.
    /// The modifier 'A' indicates that the operation is adjointable. 
    ///
    /// # Input
    /// ## oracle
    /// An operation $U$ representing the gate to be repeated.
    /// ## power
    /// The number of times that $U$ is to be repeated.
    ///
    /// # Output
    /// A new operation representing $U^m$, where $m = \texttt{power}$.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The type of the operation to be powered. 
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.operationpow"
    function OperationPowA<'T>(oracle : ('T => () : Adjoint), power : Int)  : ('T => () : Adjoint)
    {
        return OperationPowImplA(oracle, power, _);
    }

    /// # Summary
    /// Given an operation representing a gate $U$, returns a new operation
    /// $U^m$ for a power $m$.
    /// The modifier 'CA' indicates that the operation is controllable and adjointable.
    ///
    /// # Input
    /// ## oracle
    /// An operation $U$ representing the gate to be repeated.
    /// ## power
    /// The number of times that $U$ is to be repeated.
    ///
    /// # Output
    /// A new operation representing $U^m$, where $m = \texttt{power}$.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The type of the operation to be powered. 
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.operationpow"
    function OperationPowCA<'T>(oracle : ('T => () : Controlled, Adjoint), power : Int)  : ('T => () : Controlled, Adjoint)
    {
        return OperationPowImplCA(oracle, power, _);
    }

}
