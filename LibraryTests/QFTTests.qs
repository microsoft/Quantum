// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {

    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    // To test QFT we hard code circuits based on Figure 5.1 on Page 219 of 
    // [ *Michael A. Nielsen , Isaac L. Chuang*,
    //    Quantum Computation and Quantum Information ](http://doi.org/10.1017/CBO9780511976667)

    /// # Summary 
    /// Hard-code 1 qubit QFT
    operation QFT1 ( target : BigEndian ) : () { 
        body {
            AssertIntEqual(Length(target), 1, "`Length(target)` must be 1" );
            H(target[0]);
        }
        adjoint auto
    }

    /// # Summary 
    /// Hard-code 2 qubit QFT
    operation QFT2 ( target : BigEndian ) : () { 
        body {
            AssertIntEqual(Length(target), 2, "`Length(target)` must be 2" );
            let (q1,q2) = (target[0],target[1]);
            H(q1);
            (Controlled R1Frac)([q2],(2,2,q1));
            H(q2);
            SWAP(q1,q2);
        }
        adjoint auto
    }

    /// # Summary 
    /// Hard-code 3 qubit QFT
    operation QFT3 ( target : BigEndian ) : () { 
        body {
            AssertIntEqual(Length(target), 3, "`Length(target)` must be 3" );
            let (q1,q2,q3) = (target[0],target[1],target[2]);
            H(q1);
            (Controlled R1Frac)([q2],(2,2,q1));
            (Controlled R1Frac)([q3],(2,3,q1));
            H(q2);
            (Controlled R1Frac)([q3],(2,2,q2));
            H(q3);
            SWAP(q1,q3);
        }
        adjoint auto
    }

    /// # Summary 
    /// Hard-code 4 qubit QFT
    operation QFT4 ( target : BigEndian ) : () { 
        body {
            AssertIntEqual(Length(target), 4, "`Length(target)` must be 4" );
            let (q1,q2,q3,q4) = (target[0],target[1],target[2],target[3]);
            H(q1);
            (Controlled R1Frac)([q2],(2,2,q1));
            (Controlled R1Frac)([q3],(2,3,q1));
            (Controlled R1Frac)([q4],(2,4,q1));
            H(q2);
            (Controlled R1Frac)([q3],(2,2,q2));
            (Controlled R1Frac)([q4],(2,3,q2));
            H(q3);
            (Controlled R1Frac)([q4],(2,2,q3));
            H(q4);
            SWAP(q1,q4);
            SWAP(q2,q3);
        }
        adjoint auto
    }

    operation ApplyBEToRegisterA( op : ( BigEndian => () : Adjoint), target : Qubit[] ) : () {
        body { 
            op(BigEndian(target));
        }
        adjoint auto
    }

    /// # Summary 
    /// Compares QFT to the hard-coded implementations
    operation QFTTest () : () {
        body {
            let testFunctions = [ QFT1; QFT2; QFT3; QFT4 ];
            for( i in 0 .. Length(testFunctions) - 1 ) {
                AssertOperationsEqualReferenced(ApplyBEToRegisterA(testFunctions[i],_),ApplyBEToRegisterA(QFT,_),i + 1);
            }
        }
    }
}
