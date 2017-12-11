// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    /// # Summary 
    /// The `Filter` function takes an array and a predicate that is defined 
    /// for the elements of the array, and returns an array that consists of 
    /// those elements that satisfy the predicate. 
    ///
    /// # Remarks
    /// The function is defined for generic types, i.e., whenever we have 
    /// an array `'T[]` and a predicate `'T -> Bool` we can filter elements. 
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of `array` elements.
    ///
    /// # Input
    /// ## predicate
    /// A function from `'T' to Boolean that is used to filter elements. 
    /// ## array
    /// An array of elements over `'T`.
	///
    /// # Output
    /// An array `'T[]` of elements that satisfy the predicate.
    function Filter<'T>(predicate : ('T -> Bool), array : 'T[]) : 'T[] {
        mutable totalFound = 0;
        mutable idxArray = new Int[Length(array)]; 
        for (idxElement in 0..Length(array) - 1) {
            if predicate(array[idxElement]) {
                set idxArray[totalFound] = idxElement;
                set totalFound = totalFound + 1;
            }
        }
        return Subarray(idxArray[0..totalFound-1], array);
    }
}
