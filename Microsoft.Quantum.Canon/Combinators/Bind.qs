// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Canon {

    /// # See Also
    /// - Microsoft.Quantum.Canon.Bind
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
    /// - Microsoft.Quantum.Canon.BindC
    /// - Microsoft.Quantum.Canon.BindA
    /// - Microsoft.Quantum.Canon.BindCA
    function Bind<'T>(operations : ('T => ())[]) : ('T => ()) {
        return BindImpl(operations, _);
    }

    /// # See Also
    /// - Microsoft.Quantum.Canon.BindA
    operation BindAImpl<'T>(operations : ('T => () : Adjoint)[], target : 'T) : () {
        body {
            for (idxOperation in 0..Length(operations) - 1) {
                let op = operations[idxOperation];
                op(target);
            }
        }
        adjoint {
            // TODO: replace with an implementation based on Reversed : 'T[] -> 'T[]
            //       and AdjointAll : ('T => () : Adjointable)[] -> ('T => () : Adjointable).
            for (idxOperation in Length(operations) - 1..-1..0) {
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
    /// - Microsoft.Quantum.Canon.Bind
    function BindA<'T>(operations : ('T => () : Adjoint)[]) : ('T => () : Adjoint) {
        return BindAImpl(operations, _);
    }

    /// # See Also
    /// - Microsoft.Quantum.Canon.BindC
    operation BindCImpl<'T>(operations : ('T => () : Controlled)[], target : 'T) : () {
        body {
            for (idxOperation in 0..Length(operations) - 1) {
                let op = operations[idxOperation];
                op(target);
            }
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
    /// - Microsoft.Quantum.Canon.Bind
    function BindC<'T>(operations : ('T => () : Controlled)[]) : ('T => () : Controlled) {
        return BindCImpl(operations, _);
    }

    /// # See Also
    /// - Microsoft.Quantum.Canon.BindCA
    operation BindCAImpl<'T>(operations : ('T => () : Adjoint, Controlled)[], target : 'T) : () {
        body {
            for (idxOperation in 0..Length(operations) - 1) {
                let op = operations[idxOperation];
                op(target);
            }
        }

        adjoint {
            for (idxOperation in Length(operations) - 1..-1..0) {
                let op = (Adjoint operations[idxOperation]);
                op(target);
            }
        }
        controlled (controls) {
            for (idxOperation in 0..Length(operations) - 1) {
                let op = (Controlled operations[idxOperation]);
                op(controls, target);
            }
        }

        controlled adjoint (controls) {
            for (idxOperation in Length(operations) - 1..-1..0) {
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
    /// - Microsoft.Quantum.Canon.Bind
    function BindCA<'T>(operations : ('T => () : Adjoint, Controlled)[]) : ('T => () : Adjoint, Controlled) {
        return BindCAImpl(operations, _);
    }

}