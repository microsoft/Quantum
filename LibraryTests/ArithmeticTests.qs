// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;

    operation InPlaceXorTestHelper( testValue : Int, numberOfQubits : Int ) : () {
        body { 
            using (register = Qubit[numberOfQubits]) {
                let registerLE = LittleEndian(register);
                InPlaceXorLE(testValue, registerLE);
                let measuredValue = MeasureInteger(registerLE);
                AssertIntEqual(testValue, measuredValue, "Did not measure the integer we expected.");
            }
        }
    }

    operation  InPlaceXorLETest() : () {
        body {
            ApplyToEach( InPlaceXorTestHelper, [(63,6);(42,6)] );
        }
    }

    operation IntegerIncrementLETestHelper( summand1 : Int, summand2 : Int, numberOfQubits : Int ) : () {
        body {
            using (register = Qubit[numberOfQubits]) {
                let registerLE = LittleEndian(register);
                InPlaceXorLE(summand1, registerLE);
                IntegerIncrementLE( summand2, registerLE );
                let expected = Modulus(summand1 + summand2, 2 ^ numberOfQubits );
                let actual = MeasureInteger(registerLE);
                AssertIntEqual(expected, actual, $"Expected {expected}, got {actual}");
            }
        }
    }

    /// # Summary 
    /// Exhaustively tests Microsoft.Quantum.Canon.IntegerIncrementLE
    /// on 4 qubits
    operation IntegerIncrementLETest() : () {
        body {
            let numberOfQubits = 4;
            for( summand1 in 0 .. 2^numberOfQubits - 1 ) {
                for( summand2 in -2^numberOfQubits .. 2^numberOfQubits ) {
                    IntegerIncrementLETestHelper( summand1, summand2, numberOfQubits );
                }
            }
        }
    }

    operation ModularIncrementLETestHelper(
              summand1 : Int, 
              summand2 : Int, 
              modulus : Int, 
              numberOfQubits : Int ) : () 
    {
        body {
            using (register = Qubit[numberOfQubits]) {
                let registerLE = LittleEndian(register);
                InPlaceXorLE(summand1, registerLE);
                ModularIncrementLE( summand2, modulus, registerLE );
                let expected = Modulus(summand1 + summand2, modulus );
                let actual = MeasureInteger(registerLE);
                AssertIntEqual(expected, actual, $"Expected {expected}, got {actual}");

                using( controls = Qubit[2] )
                {
                    InPlaceXorLE(summand1, registerLE);
                    (Controlled ModularIncrementLE)(controls,(summand2, modulus, registerLE));
                    let actual2 = MeasureInteger(registerLE);
                    AssertIntEqual(summand1, actual2, $"Expected {summand1}, got {actual2}");

                    // now set all controls to 1
                    InPlaceXorLE(summand1, registerLE);
                    (ControlledOnInt(0,ModularIncrementLE(summand2, modulus,_)))(controls, registerLE);
                    let actual3 = MeasureInteger(registerLE);
                    AssertIntEqual(expected, actual3, $"Expected {expected}, got {actual3}");
                    // restore controls back to |0⟩ 
                }
            }
        }
    }

    /// # Summary 
    /// Exhaustively tests Microsoft.Quantum.Canon.ModularIncrementLE
    /// on 4 qubits with modulus 13
    operation ModularIncrementLETest() : () {
        body {
            let numberOfQubits = 4;
            let modulus = 13;
            for( summand1 in 0 .. modulus - 1 ) {
                for( summand2 in 0 .. modulus - 1 ) {
                    ModularIncrementLETestHelper( summand1, summand2, modulus, numberOfQubits );
                }
            }
        }
    }

    operation ModularAddProductLETestHelper(
              summand : Int, 
              multiplier1 : Int, 
              multiplier2 : Int,
              modulus : Int, 
              numberOfQubits : Int ) : () 
    {
        body {
            using (register = Qubit[numberOfQubits * 2]) {
                let summandLE = LittleEndian(register[ 0 .. numberOfQubits - 1 ]);
                let multiplierLE = LittleEndian(register[ numberOfQubits .. 2*numberOfQubits - 1 ]);

                InPlaceXorLE(summand, summandLE);
                InPlaceXorLE(multiplier1, multiplierLE);

                ModularAddProductLE( multiplier2, modulus, multiplierLE, summandLE );

                let expected = Modulus(summand + multiplier1 * multiplier2, modulus );
                let actual = MeasureInteger(summandLE);
                let actualMult = MeasureInteger(multiplierLE);
                AssertIntEqual(expected, actual, $"Expected {expected}, got {actual}");
                AssertIntEqual(multiplier1, actualMult, $"Expected {multiplier1}, got {actualMult}");
            }
        }
    }

    /// # Summary 
    /// Exhaustively tests Microsoft.Quantum.Canon.ModularAddProductLE
    /// on 4 qubits with modulus 13
    operation ModularAddProductLETest() : () {
        body {
            let numberOfQubits = 4;
            let modulus = 13;
            for( summand in 0 .. modulus - 1 ) {
                for( multiplier1 in 0 .. modulus - 1 ) {
                    for( multiplier2 in 0 .. modulus - 1) {
                        ModularAddProductLETestHelper( summand, multiplier1, multiplier2, modulus, numberOfQubits );
                    }
                }
            }
        }
    }

    operation ModularMultiplyByConstantLETestHelper(
            multiplier1 : Int, 
            multiplier2 : Int,
            modulus : Int, 
            numberOfQubits : Int ) : () 
    {
        body {
            using (register = Qubit[numberOfQubits]) {
                if( IsCoprime(multiplier2,modulus) ) {
                    let multiplierLE = LittleEndian(register);
                    InPlaceXorLE(multiplier1, multiplierLE);

                    ModularMultiplyByConstantLE( multiplier2, modulus, multiplierLE );

                    let expected = Modulus( multiplier1 * multiplier2, modulus );
                    let actualMult = MeasureInteger(multiplierLE);
                    AssertIntEqual(expected, actualMult, $"Expected {expected}, got {actualMult}");
                }
            }
        }
    }

    /// # Summary 
    /// Exhaustively tests Microsoft.Quantum.Canon.ModularMultiplyByConstantLE
    /// on 4 qubits with modulus 13
    operation ModularMultiplyByConstantLETest() : () {
        body {
            let numberOfQubits = 4;
            let modulus = 13;
            for( multiplier1 in 0 .. modulus - 1 ) {
                for( multiplier2 in 0 .. modulus - 1) {
                    ModularMultiplyByConstantLETestHelper( multiplier1, multiplier2, modulus, numberOfQubits );
                }
            }
        }
    }
}
