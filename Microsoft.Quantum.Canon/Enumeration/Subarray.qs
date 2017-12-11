// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # Summary 
    /// Takes an array and a list of locations and 
    /// produces a new array formed from the elements of the original 
    /// array that match the given locations.
    ///
    /// # Remarks
    /// The function is defined for generic types, i.e., whenever we have 
    /// an array `'T[]` and a list of locations `Int[]` defining the subarray.
    /// The construction of the subarray is a based on generating a new, deep 
    /// copy of the given array as opposed to maintaining references. 
    ///
    /// If `Length(indices) < Lenth(array)`, this function will return a
    /// subset of `array`. On the other hand, if `indices` contains repeated
    /// elements, the corresponding elements of `array` will likewise be
    /// repeated.
    /// If `indices` and `array` are the same length, this this function
    /// provides permutations of `array`.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of `array` elements.
    ///
    /// # Input
    /// ## indices
    /// A list of integers that is used to define the subarray. 
    /// ## array
    /// An array of elements over `'T`.
    ///
    /// # Output
    /// An array `out` of elements whose indices correspond to the subarray,
    /// such that `out[idx] == array[indices[idx]]`.
    function Subarray<'T>(indices : Int[], array : 'T[]) : 'T[] {
        let nSliced = Length(indices);
        mutable sliced = new 'T[nSliced];
        for( idx in 0..nSliced - 1 ) {
            set sliced[idx] = array[indices[idx]];
        }
        return sliced;
    }

}
