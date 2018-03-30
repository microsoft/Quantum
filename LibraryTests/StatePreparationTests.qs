// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;


    // tpye of test, number of qubits, abs(amplitude), phase
    newtype StatePreparationTestCases = (Int, Int, Double[], Double[]);

    function StatePreparationTestNormalizeInput(coefficients: Double[]) : Double[]{
        let nCoefficients = Length(coefficients);
        mutable norm = 0.0;
        mutable output = new Double[nCoefficients];
        for(idx in 0..nCoefficients-1){
            set norm = norm + coefficients[idx]*coefficients[idx];
        }
        for(idx in 0..nCoefficients-1){
            set output[idx] = coefficients[idx] / Sqrt(norm);
        }
        return output;
    }

    operation StatePreparationTest () : () {
        body{
            let tolerance = 10e-5;

            mutable testCases = new StatePreparationTestCases[11];
            mutable nTests = 0;

            // Test positive coefficients.
            set testCases[nTests] = StatePreparationTestCases(0, 1, [0.773761; 0.633478], [0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 2, [0.183017; 0.406973; 0.604925; 0.659502], [0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 3, [0.0986553; 0.359005; 0.465689; 0.467395; 0.419893; 0.118445; 0.461883; 0.149609], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 4, [0.271471; 0.0583654; 0.11639; 0.36112; 0.307383; 0.193371; 0.274151; 0.332542; 0.130172; 0.222546; 0.314879; 0.210704; 0.212429; 0.245518; 0.30666; 0.22773], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            // Test negative coefficients. Should give same probabilities as positive coefficients.
            set testCases[nTests] = StatePreparationTestCases(0, 1, [-0.773761; 0.633478], [0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 2, [0.183017; -0.406973; 0.604925; 0.659502], [0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 3, [0.0986553; -0.359005; 0.465689; -0.467395; 0.419893; 0.118445; -0.461883; 0.149609], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCases(0, 4, [-0.271471; 0.0583654; 0.11639; 0.36112; -0.307383; 0.193371; -0.274151; 0.332542; 0.130172; 0.222546; 0.314879; -0.210704; 0.212429; 0.245518; -0.30666; -0.22773], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;

            // Test unnormalized coefficients
            set testCases[nTests] = StatePreparationTestCases(0, 3, [1.0986553; 0.359005; 0.465689; -0.467395; 0.419893; 0.118445; 0.461883; 0.149609], new Double[0]);
            set nTests = nTests + 1;

            // Test missing coefficicients
            set testCases[nTests] = StatePreparationTestCases(0, 3, [1.0986553; 0.359005; 0.465689; -0.467395; 0.419893; 0.118445], new Double[0]);
            set nTests = nTests + 1;

            // Test phase factor on uniform superposition
            //set testCases[nTests] = StatePreparationTestCases(1, 3, [1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0], [1.0986553; 0.359005; 0.465689; -0.467395; 0.419893; 0.118445; 0.461883; 0.149609]);
            set testCases[nTests] = StatePreparationTestCases(1, 3, [1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; PI()]);
            
            set nTests = nTests + 1;

            // Loop over multiple qubit tests
            for(idxTest in 0..Length(testCases)-1){
                let (testType, nQubits, coefficientsAmplitude, coefficientsPhase) = testCases[idxTest];
                let nCoefficients = Length(coefficientsAmplitude);


                // Test negative coefficicients. Should give same results as positive coefficients.

                using(qubits = Qubit[nQubits]){
                    let qubitsBE = BigEndian(qubits);

                    if(testType == 0){
                        (StatePreparationRealCoefficients(coefficientsAmplitude))(qubitsBE);
                        let normalizedCoefficients = StatePreparationTestNormalizeInput(coefficientsAmplitude);
                        for(idxCoeff in 0..(nCoefficients-1)){
                            let amp = normalizedCoefficients[idxCoeff];
                            let prob = amp * amp;
                            AssertProbIntBE(idxCoeff, prob, qubitsBE, tolerance);
                        }
                    }
                    
                    // Test phases on uniform superposition
                    if(testType == 1){
                        mutable coefficients = new ComplexPolar[nCoefficients];
                        for(idxCoeff in 0..nCoefficients-1){
                            set coefficients[idxCoeff] = ComplexPolar(coefficientsAmplitude[idxCoeff], coefficientsPhase[idxCoeff]);
                        }

                        using(control = Qubit[1]){
                            H(control[0]);
                            (Controlled StatePreparationSBM(coefficients, _))(control, qubitsBE);
                            X(control[0]);
                            (Controlled ApplyToEachCA(H, _))(control, qubitsBE);
                            X(control[0]);

                            for(idxCoeff in 0..(nCoefficients-1)){
                                let phase = coefficientsPhase[idxCoeff];
                                //AssertPhase(-0.5 * phase, control[0], tolerance);
                            }

                            ResetAll(control);
                        }
                    }

                    ResetAll(qubits);

                }


                    //mutable coefficients = new ComplexPolar[nCoefficients];
                 //   for(idxCoeff in 0..nCoefficients-1){
                 //       set coefficients[idxCoeff] = ComplexPolar(coefficientsAmplitude[idxCoeff], coefficientsPhase[idxCoeff]);
                 //   }

            }
        }
    }
}
