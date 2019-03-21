// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.QCLA {
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Extensions.Testing;
    open Microsoft.Quantum.Extensions.Diagnostics;


    //////////////////////////////////////////////////////////////////
    // Basic edge case tests /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    operation T_1BitAdd_Test() : Unit {
        using ((a,b,c) = (Qubit[1], Qubit[1], Qubit[2])) {
            
            // a = b = 0
            QCLA(a,b,c);
            AssertQubit(Zero, c[0]);
            
            // a = 0, b = 1
            X(b[0]);
            QCLA(a,b,c);
            AssertQubit(One,c[0]); 
            X(b[0]);
            X(c[0]);

            //a = 1, b = 0
            X(a[0]);
            QCLA(a,b,c);
            AssertQubit(One, c[0]);
            X(c[0]);

            //a = 1, b = 1
            X(b[0]);
            QCLA(a,b,c);
            AssertQubit(Zero, c[0]);
            AssertQubit(One, c[1]);

            ResetAll(a);
            ResetAll(b);
            ResetAll(c);
        }
    }


    //////////////////////////////////////////////////////////////////
    // QCLA Tests
    //////////////////////////////////////////////////////////////////

    operation T_1024Bit_OnePlusOne_Test() : Unit {
        using((A, B, C) = (Qubit[1024], Qubit[1024], Qubit[1025])) {
            X(A[0]);
            X(B[0]);
            QCLA(A, B, C);
            AssertQubit(One, C[1]);
            X(C[1]);
            AssertAllZero(C);

            ResetAll(A);
            ResetAll(B);
            ResetAll(C);
        }
    }

    operation T_BasicAddition_Test() : Unit {
        using ((a,b,c) = (Qubit[4], Qubit[4], Qubit[5])) {
            
            // a = b = 0
            QCLA(a,b,c);
            AssertQubit(Zero, c[0]);
            
            // a = 0, b = 1
            X(b[0]);
            QCLA(a,b,c);
            AssertQubit(One,c[0]); 
            X(b[0]);
            X(c[0]);

            //a = 1, b = 0
            X(a[0]);
            QCLA(a,b,c);
            AssertQubit(One, c[0]);
            X(c[0]);

            //a = 1, b = 1
            X(b[0]);
            QCLA(a,b,c);
            AssertQubit(Zero, c[0]);
            AssertQubit(One, c[1]);

            ResetAll(a);
            ResetAll(b);
            ResetAll(c);
        }
    }

    operation T_TestSet_Test() : Unit {
        using (x = Qubit[4]) {
            Set(x, 15);
            AssertQubit(One, x[0]);
            AssertQubit(One, x[1]);
            AssertQubit(One, x[2]);
            AssertQubit(One, x[3]);
            ResetAll(x);
        }
    }

    operation T_BigNumbers_Test() : Unit {
        Add(6, 31, 31);
        Add(8, 100, 100);
        Add(16, 34080, 384);
        Add(16, 12345, 12345);
        Add(16, 0, 0);
        Add(32, 12345, 12345);
        Add(58, 0, 0);
    } 

    operation T_64Bit_Test() : Unit {
        using((A, B, C) = (Qubit[64], Qubit[64], Qubit[65])) {
            X(A[63]);
            X(B[63]);
            QCLA(A, B, C);
            AssertQubit(One, C[64]);
            X(C[64]);
            AssertAllZero(C);

            ResetAll(A);
            ResetAll(B);
            ResetAll(C);
        }
    }

    operation T_NBit(n : Int, func : Int) : Unit {
          using((A, B, C, d) = (Qubit[n], Qubit[n], Qubit[n + 1], Qubit())) {
            X(A[0]);
            X(B[0]);
            if (func == 0) {
                QCLA(A, B, C);
            }
            elif (func == 1) {
                ModularAddProductLE(1, 2^n, LittleEndian(A), LittleEndian(B));
            }
            elif (func == 2) {
                nBitRCA_Reference(A, B, C, d);
            }
            AssertQubit(One, C[1]);
            X(C[n]);
            AssertAllZero(C);

            ResetAll(A);
            ResetAll(B);
            ResetAll(C);
            Reset(d);
        }      
    }

    operation Add(N : Int, a : Int, b : Int) : Unit {
        using((A, B, C) = (Qubit[N], Qubit[N], Qubit[N + 1])) {
            Set(A, a);
            Set(B, b);

            QCLA(A, B, C);

            // Reset to zero
            Set(C, a + b);
            
            for (i in 0 .. N) {
                AssertQubit(Zero, C[i]);
            }

            AssertAllZero(C);

            ResetAll(A);
            ResetAll(B);
            ResetAll(C);
        }

    }

    operation Set(x : Qubit[], n : Int) : Unit{
        body (...) {
            let N = Length(x);
            mutable a = n;
            for (i in 1 .. N) {
                let k = (N - i);
                if (a >= 2^k) {
                    set a = a - 2^k;
                    X(x[k]);
                }
            }
        }
    }

}
