// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Converts a `Result` type to a `Bool` type, where `One` is mapped to 
    /// `true` and `Zero` is mapped to `false`.
    ///
    /// # Input
    /// ## input
    /// `Result` to be converted.
    /// 
    /// # Output
    /// A `Bool` representing the `input`.
    function BoolFromResult( input: Result) : Bool
    {
        if(input == Zero) {
            return false;
        }
        else {
            return true;
        }
    }

    /// # Summary
    /// Converts a `Bool` type to a `Result` type, where `true` is mapped to 
    /// `One` and `false` is mapped to `Zero`.
    ///
    /// # Input
    /// ## input
    /// `Bool` to be converted.
    /// 
    /// # Output
    /// A `Result` representing the `input`.
    function ResultFromBool( input: Bool) : Result
    {
        if(input == false) {
            return Zero;
        }
        else {
            return One;
        }
    }

     /// # Summary
    /// Converts a `Result[]` type to a `Bool[]` type, where `One` is mapped to 
    /// `true` and `Zero` is mapped to `false`.
    ///
    /// # Input
    /// ## input
    /// `Result[]` to be converted.
    /// 
    /// # Output
    /// A `Bool[]` representing the `input`.
    function BoolArrFromResultArr(input : Result[]) : Bool[]
    {
        let nInput = Length(input);
        mutable output = new Bool[nInput];
        for (idx in 0..nInput - 1) {
            set output[idx] = BoolFromResult(input[idx]);
        }
        return output;
    }

    /// # Summary
    /// Converts a `Bool[]` type to a `Result[]` type, where `true` is mapped to 
    /// `One` and `false` is mapped to `Zero`.
    ///
    /// # Input
    /// ## input
    /// `Bool[]` to be converted.
    /// 
    /// # Output
    /// A `Result[]` representing the `input`.
    function ResultArrFromBoolArr(input : Bool[]) : Result[]
    {
        let nInput = Length(input);
        mutable output = new Result[nInput];
        for (idx in 0..nInput - 1) {
            set output[idx] = ResultFromBool(input[idx]);
        }
        return output;
    }

    /// # Summary
    /// Produces binary representation of positive integer in little Endian format.
    ///
    /// # Input
    /// ## number
    /// Positive integer.
    /// ## bits
    /// Bits in binary representation of number.
    /// 
    /// # Remarks
    /// The input `number` must be at most 2^bits -1.
    function BoolArrFromPositiveInt(number : Int, bits : Int) : Bool[]
    {
        AssertBoolEqual(
            (number >= 0) && ( number < 2^bits ), true, 
            "`number` must be between 0 and 2^`bits` - 1" );

        mutable outputBits = new Bool[bits];
        mutable tempInt = number;

        for ( idxBit in 0..bits - 1 ) {
            if ( tempInt % 2 == 0 ){
                set outputBits[idxBit] = false;
            }
            else {
                set outputBits[idxBit] = true;
            }
            set tempInt = tempInt / 2;
        }

        return outputBits;
    }

    /// # Summary
    /// Produces a positive integer from a string of bits in in little Endian format.
    ///
    /// # Input
    /// ## bits
    /// Bits in binary representation of number.
    function PositiveIntFromBoolArr(bits : Bool[]) : Int
    {
        AssertBoolEqual(
            Length(bits) < 64, true, 
            "`Length(bits)` must be less than 64" );

        mutable number = 0;
        let nBits = Length(bits) ;

        for ( idxBit in 0..nBits - 1 ) {
            if (bits[idxBit]) {
                set number = number + 2 ^ idxBit;
            }
        }
        return number;
    }

    /// # Summary
    /// Produces a positive integer from a string of Results in in little Endian format.
    ///
    /// # Input
    /// ## results
    /// Results in binary representation of number.
    function PositiveIntFromResultArr(results :Result[]) : Int
    {
        return PositiveIntFromBoolArr(BoolArrFromResultArr(results));
    }

    /// # Summary 
    /// Used to cast UDTs that are derived from type Qubit[] down to Qubit[].
    /// Handy when used with generic functions like Head and Tail.
    function AsQubitArray( arr : Qubit[] ) : Qubit[] {
        return arr;
    }
}
