// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    /// # Summary
    /// The `Map` function takes an array and a function that is defined
    /// for the elements of the array, and returns a new array that consists
    /// of the images of the original array under the function.
    ///
    /// # Remarks
    /// The function is defined for generic types, i.e., whenever we have
    /// an array `'T[]` and a function `mapper: 'T -> 'U` we can map the elements
    /// of the array and produce a new array of type `'U[]`.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of `array` elements.
    /// ## 'U
    /// The result type of the `mapper` function.
    ///
    /// # Input
    /// ## mapper
    /// A function from `'T` to `'U` that is used to map elements.
    /// ## array
    /// An array of elements over `'T`.
    ///
    /// # Output
    /// An array `'U[]` of elements that are mapped by the `mapper` function.
    function Map<'T, 'U>(mapper : ('T -> 'U), array : 'T[]) : 'U[] {
        mutable resultArray = new 'U[Length(array)];
        for (idxElement in 0..Length(array) - 1) {
            set resultArray[idxElement] = mapper(array[idxElement]);
        }
        return resultArray;
    }

    /// # Summary
    /// The `MapIndex` function takes an array and a function that is defined
    /// for the indexed elements of the array, and returns a new array that consists
    /// of the images of the original array under the function.
    ///
    /// # Remarks
    /// The function is defined for generic types, i.e., whenever we have
    /// an array `'T[]` and a function `mapper: (Int, 'T) -> 'U` we can map the elements
    /// of the array and produce a new array of type `'U[]`.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of `array` elements.
    /// ## 'U
    /// The result type of the `mapper` function.
    ///
    /// # Input
    /// ## mapper
    /// A function from `(Int, 'T)` to `'U` that is used to map elements
    /// and their indices.
    /// ## array
    /// An array of elements over `'T`.
    ///
    /// # Output
    /// An array `'U[]` of elements that are mapped by the `mapper` function.
    ///
    /// # Example
    /// The following two lines are equivalent:
    /// ```Q#
    /// let arr = MapIndex(f, [x0; x1; x2]);
    /// let arr = [f(0, x0); f(1, x1), f(2; x2)];
    /// ```
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.map"
    function MapIndex<'T, 'U>(mapper : ((Int, 'T) -> 'U), array : 'T[]) : 'U[] {
        mutable resultArray = new 'U[Length(array)];
        for (idxElement in 0..Length(array) - 1) {
            set resultArray[idxElement] = mapper(idxElement, array[idxElement]);
        }
        return resultArray;
    }
}
