// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Canon;    

    function ResultAsIntTest() : () {
        AssertIntEqual(ResultAsInt([Zero; Zero]), 0, "Expected [Zero; Zero] to be represented by 0.");
        AssertIntEqual(ResultAsInt([One;  Zero]), 1, "Expected [One; Zero] to be represented by 1.");
        AssertIntEqual(ResultAsInt([Zero; One]),  2, "Expected [Zero; One] to be represented by 2.");
        AssertIntEqual(ResultAsInt([One;  One]),  3, "Expected [One; One] to be represented by 3.");
    }
   

    function BoolArrFromPositiveIntTest() : (){
        for (number in 0..100) {
            let bits = BoolArrFromPositiveInt(number, 9);
            let inte = PositiveIntFromBoolArr(bits);
            AssertIntEqual(inte, number, "Integer converted to bit string and back should be identical");
        }

        let bits70 = [false; true; true; false; false; false; true; false];
        let number70 = PositiveIntFromBoolArr(bits70);
        AssertIntEqual(70, number70, "Integer from 01000110 in little Endian should be 70");
    }

}
