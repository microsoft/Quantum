// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # See Also
    /// - @"microsoft.quantum.canon.bind"
    operation BindImpl<'T>(operations : ('T => ())[], target : 'T) : () {
        body {
            for (idxOperation in 0..Length(operations) - 1) {
                let op = operations[idxOperation];
                op(target);
            }
        }
    }

    /// # Summary
    /// Given an array of operations acting on a single input,
    /// produces a new operation that
    /// performs each given operation in sequence.
    ///
    /// # Input
    /// ## operations
    /// A sequence of operations to be performed on a given input.
    ///
    /// # Output
    /// A new operation that performs each given operation in sequence
    /// on its input.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The target on which each of the operations in the array act.
    ///
    /// # Example
    /// The following are equivalent:
    /// ```Q#
    /// let bound = Bind([U; V]);
    /// bound(x);
    ///
    /// U(x); V(x);
    /// ```
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.bindc"
    /// - @"microsoft.quantum.canon.binda"
    /// - @"microsoft.quantum.canon.bindca"
    function Bind<'T>(operations : ('T => ())[]) : ('T => ()) {
        return BindImpl(operations, _);
    }

    /// # See Also
    /// - @"microsoft.quantum.canon.binda"
    operation BindAImpl<'T>(operations : ('T => () : Adjoint)[], target : 'T) : () {
        body {
            BindImpl(operations, target);
        }
        adjoint {
            // TODO: replace with an implementation based on Reversed : 'T[] -> 'T[]
            //       and AdjointAll : ('T => () : Adjointable)[] -> ('T => () : Adjointable).
            for (idxOperation in Length(operations) - 1..0) {
                let op = (Adjoint operations[idxOperation]);
                op(target);
            }
        }
    }

    /// # Summary
    /// Given an array of operations acting on a single input,
    /// produces a new operation that
    /// performs each given operation in sequence.
    /// The modifier 'A' indicates that all operations in the array are adjointable.
    ///
    /// # Input
    /// ## operations
    /// A sequence of operations to be performed on a given input.
    ///
    /// # Output
    /// A new operation that performs each given operation in sequence
    /// on its input.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The target on which each of the operations in the array act.
    ///
    /// # Example
    /// The following are equivalent:
    /// ```Q#
    /// let bound = Bind([U; V]);
    /// bound(x);
    ///
    /// U(x); V(x);
    /// ```
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.bind"
    function BindA<'T>(operations : ('T => () : Adjoint)[]) : ('T => () : Adjoint) {
        return BindAImpl(operations, _);
    }

    /// # See Also
    /// - @"microsoft.quantum.canon.bindc"
    operation BindCImpl<'T>(operations : ('T => () : Controlled)[], target : 'T) : () {
        body {
            BindImpl(operations, target);
        }

        controlled (controls) {
            for (idxOperation in 0..Length(operations) - 1) {
                let op = (Controlled operations[idxOperation]);
                op(controls, target);
            }
        }
    }
    
    /// # Summary
    /// Given an array of operations acting on a single input,
    /// produces a new operation that
    /// performs each given operation in sequence.
    /// The modifier 'C' indicates that all operations in the array are controllable. 
    ///
    /// # Input
    /// ## operations
    /// A sequence of operations to be performed on a given input.
    ///
    /// # Output
    /// A new operation that performs each given operation in sequence
    /// on its input.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The target on which each of the operations in the array act.
    ///
    /// # Example
    /// The following are equivalent:
    /// ```Q#
    /// let bound = Bind([U; V]);
    /// bound(x);
    ///
    /// U(x); V(x);
    /// ```
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.bind"
    function BindC<'T>(operations : ('T => () : Controlled)[]) : ('T => () : Controlled) {
        return BindCImpl(operations, _);
    }

    /// # See Also
    /// - @"microsoft.quantum.canon.bindca"
    operation BindCAImpl<'T>(operations : ('T => () : Adjoint, Controlled)[], target : 'T) : () {
        body {
            BindImpl(operations, target);
        }

        adjoint {
            (Adjoint BindAImpl)(operations, target);
        }
        controlled (controls) {
            (Controlled BindCImpl)(controls, (operations, target));
        }

        controlled adjoint (controls) {
            for (idxOperation in Length(operations) - 1..0) {
                let op = (Controlled Adjoint operations[idxOperation]);
                op(controls, target);
            }
        }
    }

    /// # Summary
    /// Given an array of operations acting on a single input,
    /// produces a new operation that
    /// performs each given operation in sequence.
    /// The modifier 'CA' indicates that all operations in the array are adjointable
    /// and controllable.
    ///
    /// # Input
    /// ## operations
    /// A sequence of operations to be performed on a given input.
    ///
    /// # Output
    /// A new operation that performs each given operation in sequence
    /// on its input.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The target on which each of the operations in the array act.
    ///
    /// # Example
    /// The following are equivalent:
    /// ```Q#
    /// let bound = Bind([U; V]);
    /// bound(x);
    ///
    /// U(x); V(x);
    /// ```
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.bind"
    function BindCA<'T>(operations : ('T => () : Adjoint, Controlled)[]) : ('T => () : Adjoint, Controlled) {
        return BindCAImpl(operations, _);
    }

}