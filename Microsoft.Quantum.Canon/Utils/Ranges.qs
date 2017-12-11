// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Returns the absolute value of an integer.
    ///
    /// # Input
    /// ## input
    /// An integer $x$ of type `Int`.
    ///
    /// # Output
    /// An integer $|x|$ of type `Int`.
    function IntAbs (input : Int) : Int{ 
        mutable tmp = 0;
        if (input < 0) { 
            set tmp = -input; 
        } 
        else {
            set tmp = input; 
        }
        return tmp;             
    }
 
     /// # Summary
    /// Returns the maximum of two integers.
    ///
    /// # Input
    /// ## a
    /// An integer $a$ of type `Int`.
    /// ## b
    /// An integer $b$ of type `Int`.
    ///
    /// # Output
    /// An integer $\max{a,b}$ of type `Int`.
    function IntMax (a : Int, b : Int) : Int { 
        mutable tmp = 0;
        if (a < b) {
            set tmp = b; 
        } 
        else {
            set tmp = a;
        }
        return tmp;
    }
    
    //function IntRange (range : Range) : Int[] {
    //    mutable resultArray = new Int[ IntMax( IntAbs(range.start), IntAbs(range.stop) )]; 
     //   mutable numItems = 0;
     //   for (idx in range) { 
     //       set resultArray[numItems] = idx; 
     //       set numItems = numItems + 1;
     //   }
     //   return resultArray[0..(numItems-1)];
    //}
    
}
