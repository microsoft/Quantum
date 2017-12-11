// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Create an array that contains the same elements as an input array but in reverse
    /// order.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the array elements.
    ///
    /// # Input
    /// ## array
    /// An array whose elements are to be copied in reverse order.
    ///
    /// # Output
    /// An array containing the elements `array[Length(array) - 1]` .. `array[0]`.
    function Reverse<'T>(array : 'T[]) : 'T[] {
        let nElements = Length(array);
        mutable newArray = new 'T[nElements];

        for (idxElement in 0..nElements - 1) {
            set newArray[nElements - idxElement - 1] = array[idxElement];
        }

        return newArray;
    }

    /// # Summary
    /// Creates an array that is equal to an input array except that the first array
    /// element is dropped.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the array elements.
    ///
    /// # Input
    /// ## array
    /// An array whose second to last elements are to form the output array.
    ///
    /// # Output
    /// An array containing the elements `array[1..Length(array) - 1]`.
    function Rest<'T>(array : 'T[]) : 'T[] {
        return array[1..Length(array) - 1];
    }

    /// # Summary
    /// Creates an array that is equal to an input array except that the last array
    /// element is dropped.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the array elements.
    ///
    /// # Input
    /// ## array
    /// An array whose fisrt to second-to-last elements are to form the output array.
    ///
    /// # Output
    /// An array containing the elements `array[0..Length(array) - 2]`.
    function Most<'T>(array : 'T[]) : 'T[] {
        return array[0..Length(array) - 2];
    }

    function LookupImpl<'T>(array : 'T[], index : Int) : 'T {
        return array[index];
    }

    /// # Summary
    /// Given an array, returns a function which returns elements of that
    /// array.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the elements of the array being represented as a lookup
    /// function.
    ///
    /// # Input
    /// ## array
    /// The array to be represented as a lookup function.
    ///
    /// # Output
    /// A function `f` such that `f(idx) == f[idx]`.
    ///
    /// # Remarks
    /// This function is mainly useful for interoperating with functions and
    /// operations that take `Int -> 'T` functions as their arguments. This
    /// is common, for instance, in the generator representation library,
    /// where functions are used to avoid the need to record an entire array
    /// in memory.
    function LookupFunction<'T>(array : 'T[]) : (Int -> 'T) {
        return LookupImpl(array, _);
    }

    /// # Summary
    /// Given two arrays, returns a new array of pairs such that each pair
    /// contains an element from each original array.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the left array elements.
    /// ## 'U
    /// The type of the right array elements.
    ///
    /// # Input
    /// ## left
    /// An array containing values for the first element of each tuple.
    /// ## right
    /// An array containing values for the second element of each tuple.
    ///
    /// # Output
    /// An array containing pairs of the form `(left[idx], right[idx])` for
    /// each `idx`. If the two arrays are not of equal length, the output will
    /// be as long as the shorter of the inputs.
    ///
    /// # Example
    /// ```Q#
    /// let left = [1; 3; 71];
    /// let right = [false; true];
    /// let pairs = Zip(left, right); // [(1, false); (3, true)]
    /// ```
    function Zip<'T, 'U>(left : 'T[], right : 'U[]) : ('T, 'U)[] {
        mutable nElements = 0;
        if (Length(left) < Length(right)) {
            set nElements = Length(left);
        } else {
            set nElements = Length(right);
        }

        mutable output = new ('T, 'U)[nElements];

        for (idxElement in 0..nElements - 1) {
            set output[idxElement] = (left[idxElement], right[idxElement]);
        }

        return output;

    }

    /// # Summary
    /// Returns the last element of the array.
    ///
    /// # Type Parameters
    /// ## 'A
    /// The type of the array elements.
    ///
    /// # Input
    /// ## array
    /// Array of which the last element is taken. Array must have length at least 1.
    ///
    /// # Output
    /// The last element of the array.
    function Tail<'A> ( array : 'A[] ) : 'A {
        AssertBoolEqual(Length(array) > 0, true, "Array must be of the length at least 1" );
        return array[Length(array) - 1];
    }

    /// # Summary
    /// Returns the first element of the array.
    ///
    /// # Type Parameters
    /// ## 'A
    /// The type of the array elements.
    ///
    /// # Input
    /// ## array
    /// Array of which the first element is taken. Array must have length at least 1.
    ///
    /// # Output
    /// The first element of the array.
    function Head<'A> ( array : 'A[] ) : 'A {
        AssertBoolEqual(Length(array) > 0, true, "Array must be of the length at least 1" );
        return array[0];
    }

    /// # Summary
    /// Creates an array of given length with all elements equal to given value.
    ///
    /// # Input
    /// ## length
    /// Length of the new array.
    /// ## value
    /// A value that will be contained at each index of the new array.
    ///
    /// # Output
    /// A new array of length `length`, such that every element is `value`.
    function ConstantArray<'T>( length : Int, value : 'T ) : 'T[]
    {
        mutable arr = new 'T[length];
        for( i in 0 .. length - 1 )
        {
            set arr[i] = value;
        }
        return arr;
    }

    /// # Summary
    /// Returns an array containing the elements of another array,
    /// excluding elements at a given list of indices.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the array elements.
    ///
    /// # Input
    /// ## remove
    /// An array of indices denoting which elements should be excluded
    /// from the output.
    /// ## array
    /// Array of which the values in the output array are taken.
    ///
    /// # Output
    /// An array `output` such that `output[0]` is the first element
    /// of `array` whose index does not appear in `remove`,
    /// such that `output[1]` is the second such element, and so
    /// forth.
    ///
    /// # Example
    /// ```Q#
    /// let array = [10; 11; 12; 13; 14; 15];
    /// // The following line returns [10; 12; 15].
    /// let subarray = Exclude([1; 3; 4], array);
    /// ```
    function Exclude<'T>(remove : Int[], array : 'T[]) : 'T[] 
	{

		let nSliced = Length(remove);
		let nElements = Length(array);
		//Would be better with sort function
		//Or way to add elements to array

		mutable arrayKeep = new Int[nElements];
		mutable sliced = new 'T[nElements - nSliced];
		mutable counter = 0;

		for ( idx in 0..nElements - 1) {
			set arrayKeep[idx] = idx;
		}
		for ( idx in 0..nSliced - 1 ) {
			set arrayKeep[remove[idx]] = -1;
		}
		for ( idx in 0..nElements - 1 ) {
			if(arrayKeep[idx] >= 0){
				set sliced[counter] = array[arrayKeep[idx]];
				set counter = counter + 1;
			}
		}

		return sliced;
	}


}
