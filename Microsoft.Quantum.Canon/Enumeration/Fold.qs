// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    /// # Summary
    /// Iterates a function `f` through an array `array`, returning
    /// `f(f(f(initialState, array[0]), array[1]), ...)`.
    ///
    /// # Type Parameters
    /// ## 'State
    /// The type of states the `folder` function operates on, i.e., accepts as its first
    /// argument and returns.
    /// ## 'T
    /// The type of `array` elements.
    ///
    /// # Input
    /// ## folder
    /// A function to be folded over the array.
    /// ## state
    /// The initial state of the folder.
    /// ## array
    /// An array of values to be folded over.
    ///
    /// # Output
    /// The final state returned by the folder after iterating over
    /// all elements of `array`.
    ///
    /// # Example
    /// ```qsharp
    /// function Plus(a : Double, b : Double) { return a + b; }
    /// function Sum(xs : Double[]) {
    ///     return Fold(Plus, 0.0, xs);
    /// }
    /// ```
    function Fold<'State, 'T>(folder : (('State, 'T) -> 'State), state : 'State, array : 'T[]) : 'State {
        mutable current = state;
        for (idxElement in 0..Length(array) - 1) {
            set current = folder(current, array[idxElement]);
        }
        return current;
    }

}
