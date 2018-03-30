// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Convert;

    operation MultiplexorZTestHelper (coefficients: Double[], multiplexorControl: BigEndian, additionalControl: Qubit[], target: Qubit , tolerance: Double) : () 
    {
        body{

            let nCoefficients = Length(coefficients);
            let nQubits = Length(multiplexorControl) + Length(additionalControl) + 1;

            // Measure phase shift due to Exp^PauliZ rotation.
            H(target);

            // Generate uniform superposition over control inputs.
            for(idxMultiplexor in 0..Length(multiplexorControl)-1){
                H(multiplexorControl[idxMultiplexor]);
            }
            for(idxAdditional in 0..Length(additionalControl)-1){
                H(additionalControl[idxAdditional]);
            }

            // For deterministic test of particular number state `idx', we could use the following
            //let bits = Reverse(BoolArrFromPositiveInt (idx, Length(multiplexorControl)));
            //for(idxBits in 0..Length(bits)-1){
            //    if(bits[idxBits]){
            //        X(multiplexorControl[idxBits]);
            //    }
            //}

            // Apply MultiplexorZ circuit
            if(Length(additionalControl) == 0){
                (MultiplexorZ(coefficients))(multiplexorControl, target);
            }
            elif(Length(additionalControl) == 1){
                (Controlled ((MultiplexorZ(coefficients))(multiplexorControl, _)))(additionalControl, target);
            }
            else{
                fail "Test for more than one control on MultiplexorZ not implemented.";
            }

            // Sample from control registers and check phase using AssertProb.

            let multiplexorControlInteger = MeasureIntegerBE(multiplexorControl);
            let additionalControlResults = MultiM(additionalControl);

            if(Length(additionalControlResults) == 1 && additionalControlResults[0] == Zero){
                // Case where Identity operation is performed.
                Message($"Controlled MultiplexorZ test. coefficient {multiplexorControlInteger} of {nCoefficients-1}.");
                AssertPhase(0.0, target, tolerance); 
            }
            else{
                mutable coeff = 0.0;
                if(multiplexorControlInteger < nCoefficients){
                    set coeff = coefficients[multiplexorControlInteger];
                }

                if(Length(additionalControl)==0){
                    Message($"MultiplexorZ test. Qubits: {nQubits}; coefficient {multiplexorControlInteger} of {nCoefficients-1}.");
                    AssertPhase(coeff, target, tolerance); 
                }
                else{
                    Message($"Controlled MultiplexorZ test. Qubits: {nQubits}; coefficient {multiplexorControlInteger} of {nCoefficients-1}.");
                    AssertPhase(coeff, target, tolerance); 
                }
                //AssertPhase(coeff, target, tolerance); 


            }

            ResetAll(multiplexorControl);
            ResetAll(additionalControl);
            Reset(target);
        }
    }

    operation MultiplexorZTest () : () 
    {
        body{
            let maxQubits = 6;
            // Loop over controlled & un-controlled Multiplexor
            for(nAdditionalControl in 0..1){
                // Loop over number of Multiplexor qubits
                for(nMultiplexorControl in 0..maxQubits-2){
                    //Loop over some number of missing coefficients
                    for(missingCoefficients in 0..nMultiplexorControl){

                        // Generate some coefficients
                        let maxCoefficients = 2^nMultiplexorControl;
                        let nCoefficients = maxCoefficients - missingCoefficients;
                        mutable coefficients = new Double[nCoefficients];
                        for(idx in 0..Length(coefficients)-1){
                            set coefficients[idx] = 1.0 * ToDouble(idx+1) * 0.2;
                        }

                        // Allocate qubits
                        using(qubits = Qubit[nMultiplexorControl+1+nAdditionalControl]){
                            let multiplexorControl = BigEndian(qubits[0..nMultiplexorControl-1]);
                            let target = qubits[nMultiplexorControl];
                            mutable additionalControl = new Qubit[1];
                            if(nAdditionalControl == 0){
                                set additionalControl = new Qubit[0];
                            }
                            elif(nAdditionalControl == 1){
                                set additionalControl = [qubits[Length(qubits)-1]];
                            }

                            let tolerance = 10e-10;

                            // Repeat test some number of times
                            for(idxCoeff in 0..maxCoefficients/2){
                                MultiplexorZTestHelper (coefficients, multiplexorControl, additionalControl, target , tolerance);
                            }
                        }
                    }
                }
            }
        }
    }

    
    operation DiagonalUnitaryTestHelper (coefficients: Double[], qubits: BigEndian, tolerance: Double) : () 
    {
        body{

            let nCoefficients = Length(coefficients);
            let nQubits = Length(qubits);

            
            // The absolute phase of a diagonal unitary can only be characeterized
            // using a controlled operation.
            using(control = Qubit[1]){
                for(idxCoeff in 0..Length(coefficients) -1 ){
                    H(control[0]);           
                    //for(idxQubit in 0..nQubits-1){
                    //    H(qubits[idxQubit]);
                    //}
            

                    // For deterministic test of particular number state `idx', we could use the following
                    let bits = Reverse(BoolArrFromPositiveInt (idxCoeff, nQubits));
                    for(idxBits in 0..Length(bits)-1){
                        if(bits[idxBits]){
                            X(qubits[idxBits]);
                        }
                    }

                    // Apply MultiplexorZ circuit
                    (Controlled DiagonalUnitary(coefficients))(control, qubits);
                    Message($"DiagonalUnitary test. Qubits: {nQubits}; coefficient {idxCoeff} of {nCoefficients-1}.");
                    AssertPhase(-0.5 * coefficients[idxCoeff], control[0], tolerance); 
                    
                    ResetAll(control);
                    ResetAll(qubits);
                }
            }
        }
    }

    operation DiagonalUnitaryTest () : () 
    {
        body{
            let maxQubits = 4;
            for(nqubits in 1..maxQubits){
                // Generate some coefficients
                let maxCoefficients = 2^nqubits;
                //let nCoefficients = maxCoefficients - missingCoefficients;
                mutable coefficients = new Double[maxCoefficients];
                for(idx in 0..Length(coefficients)-1){
                    set coefficients[idx] = 1.0 * ToDouble(idx+1) * 0.3;
                }

                // Allocate qubits
                using(qubits = Qubit[nqubits]){
                    let tolerance = 10e-10;
                    DiagonalUnitaryTestHelper (coefficients, BigEndian(qubits) , tolerance);
                    
                }
            }
        }
    }
    // TODO Multiplexor Pauli tests.
}
