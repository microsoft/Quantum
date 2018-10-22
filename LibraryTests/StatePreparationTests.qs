// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;


    // number of qubits, abs(amplitude), phase
    newtype StatePreparationTestCase = (Int, Double[], Double[]);

    operation StatePreparationPositiveCoefficientsTest () : () {
        body{
            let tolerance = 10e-10;

            mutable testCases = new StatePreparationTestCase[100];
            mutable nTests = 0;

            // Test positive coefficients.
            set testCases[nTests] = StatePreparationTestCase(1, [0.773761; 0.633478], [0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(2, [0.183017; 0.406973; 0.604925; 0.659502], [0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(3, [0.0986553; 0.359005; 0.465689; 0.467395; 0.419893; 0.118445; 0.461883; 0.149609], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(4, [0.271471; 0.0583654; 0.11639; 0.36112; 0.307383; 0.193371; 0.274151; 0.332542; 0.130172; 0.222546; 0.314879; 0.210704; 0.212429; 0.245518; 0.30666; 0.22773], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            // Test negative coefficients. Should give same probabilities as positive coefficients.
            set testCases[nTests] = StatePreparationTestCase(1, [-0.773761; 0.633478], [0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(2, [0.183017; -0.406973; 0.604925; 0.659502], [0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(3, [0.0986553; -0.359005; 0.465689; -0.467395; 0.419893; 0.118445; -0.461883; 0.149609], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(4, [-0.271471; 0.0583654; 0.11639; 0.36112; -0.307383; 0.193371; -0.274151; 0.332542; 0.130172; 0.222546; 0.314879; -0.210704; 0.212429; 0.245518; -0.30666; -0.22773], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;

            // Test unnormalized coefficients
            set testCases[nTests] = StatePreparationTestCase(3, [1.0986553; 0.359005; 0.465689; -0.467395; 0.419893; 0.118445; 0.461883; 0.149609], new Double[0]);
            set nTests = nTests + 1;

            // Test missing coefficients
            set testCases[nTests] = StatePreparationTestCase(3, [1.0986553; 0.359005; 0.465689; -0.467395; 0.419893; 0.118445], new Double[0]);
            set nTests = nTests + 1;

            // Loop over multiple qubit tests
            for(idxTest in 0..nTests-1){
                let (nQubits, coefficientsAmplitude, coefficientsPhase) = testCases[idxTest];
                let nCoefficients = Length(coefficientsAmplitude);


                // Test negative coefficients. Should give same results as positive coefficients.
                using(qubits = Qubit[nQubits]){
                    let qubitsBE = BigEndian(qubits);

                    let op = StatePreparationPositiveCoefficients(coefficientsAmplitude);
                    op(qubitsBE);
                    let normalizedCoefficients = PNormalize(2.0, coefficientsAmplitude);
                    for(idxCoeff in 0..(nCoefficients-1)){
                        let amp = normalizedCoefficients[idxCoeff];
                        let prob = amp * amp;
                        AssertProbIntBE(idxCoeff, prob, qubitsBE, tolerance);
                    }

                    ResetAll(qubits);
                }
            }
        }
    }

    // Test phase factor on 1-qubit uniform superposition.
    operation StatePreparationComplexCoefficientsQubitPhaseTest () : () {
        body{
            let tolerance = 10e-10;

            mutable testCases = new StatePreparationTestCase[10];
            mutable nTests = 0;

            // Test phase factor on uniform superposition.
            set testCases[nTests] = StatePreparationTestCase(1, [1.0; 1.0], [0.01; -0.01]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(1, [1.0; 1.0], [0.01; -0.05]);
            set nTests = nTests + 1;

            // Loop over tests
            for(idxTest in 0..nTests-1){
                let (nQubits, coefficientsAmplitude, coefficientsPhase) = testCases[idxTest];
                Message($"Test case {idxTest}");
                let nCoefficients = Length(coefficientsAmplitude);


                using(qubits = Qubit[nQubits]){
                    let qubitsBE = BigEndian(qubits);
                    mutable coefficients = new ComplexPolar[nCoefficients];
                    mutable coefficientsPositive = new Double[nCoefficients];
                    for(idxCoeff in 0..nCoefficients-1){
                        set coefficients[idxCoeff] = ComplexPolar(coefficientsAmplitude[idxCoeff], coefficientsPhase[idxCoeff]);
                        set coefficientsPositive[idxCoeff] = coefficientsAmplitude[idxCoeff];
                    }
                    let normalizedCoefficients = PNormalize(2.0, coefficientsAmplitude);

                    // Test phase factor on uniform superposition
                    let phase = 0.5 * (coefficientsPhase[0]-coefficientsPhase[1]);
                    let amp = normalizedCoefficients[0];
                    let prob = amp * amp;
                    let op = StatePreparationComplexCoefficients(coefficients);
                    op(qubitsBE);

                    AssertProbIntBE(0, prob, qubitsBE, tolerance);
                    AssertProbIntBE(1, prob, qubitsBE, tolerance);
                    AssertPhase(phase, qubitsBE[0], tolerance);
                    ResetAll(qubits);
                }
            }
        }
    }

 
    // Test probabilities and phases factor of multi-qubit uniform superposition.   
    operation StatePreparationComplexCoefficientsMultiQubitPhaseTest () : () {
        body{
            let tolerance = 10e-10;

            mutable testCases = new StatePreparationTestCase[10];
            mutable nTests = 0;

            // Test probability and phases of uniform superposition.
            set testCases[nTests] = StatePreparationTestCase(1, [1.0; 1.0], [0.01; -0.01]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(3, [1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(3, [1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0], [PI(); PI(); PI(); PI(); PI(); PI(); PI(); PI()]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(3, [1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0], [0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0; 0.01]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(3, [1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0; 1.0], [1.0986553; 0.359005; 0.465689; -0.467395; 0.419893; 0.118445; 0.461883; 0.149609]);
            set nTests = nTests + 1;

            // Loop over tests
            for(idxTest in 0..nTests-1){
                let (nQubits, coefficientsAmplitude, coefficientsPhase) = testCases[idxTest];
                Message($"Test case {idxTest}");
                let nCoefficients = Length(coefficientsAmplitude);


                using(qubits = Qubit[nQubits]){
                    let qubitsBE = BigEndian(qubits);
                    mutable coefficients = new ComplexPolar[nCoefficients];
                    mutable coefficientsPositive = new Double[nCoefficients];
                    for(idxCoeff in 0..nCoefficients-1){
                        set coefficients[idxCoeff] = ComplexPolar(coefficientsAmplitude[idxCoeff], coefficientsPhase[idxCoeff]);
                        set coefficientsPositive[idxCoeff] = coefficientsAmplitude[idxCoeff];
                    }
                    let normalizedCoefficients = PNormalize(2.0, coefficientsAmplitude);

                    // Test probability and phases of uniform superposition
                    let op = StatePreparationComplexCoefficients(coefficients);
                    using(control = Qubit[1]){
                        // Test probability
                        H(control[0]);
                        (Controlled op)(control, qubitsBE);
                        X(control[0]);
                        (Controlled ApplyToEachCA(H, _))(control, qubitsBE);
                        X(control[0]);
                        for(idxCoeff in 0..(nCoefficients-1)){
                            let amp = normalizedCoefficients[idxCoeff];
                            let prob = amp * amp;
                            AssertProbIntBE(idxCoeff, prob, qubitsBE, tolerance);
                        }
                        ResetAll(control);
                        ResetAll(qubits);

                        //Test phase
                        for(repeats in 0..nCoefficients/2){
                            H(control[0]);
                            (Controlled op)(control, qubitsBE);
                            X(control[0]);
                            (Controlled ApplyToEachCA(H, _))(control, qubitsBE);
                            X(control[0]);
                            let indexMeasuredInteger = MeasureIntegerBE(qubitsBE);
                            let phase = coefficientsPhase[indexMeasuredInteger];
                            Message($"StatePreparationComplexCoefficientsTest: expected phase = {phase}.");
                            AssertPhase(-0.5 * phase, control[0], tolerance);
                            ResetAll(control);
                            ResetAll(qubits);
                        }
                    }
                }
            }
        }
    }

    // Test probabilities and phases of arbitrary multi-qubit superposition.
    operation StatePreparationComplexCoefficientsArbitraryMultiQubitPhaseTest () : () {
        body{
            let tolerance = 10e-10;

            mutable testCases = new StatePreparationTestCase[10];
            mutable nTests = 0;

            set testCases[nTests] = StatePreparationTestCase(1, [1.0986553; 0.359005], [0.419893; 0.118445]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(2, [1.0986553; 0.359005; - 0.123; 9.238], [0.419893; 0.118445; -0.467395; 0.419893]);
            set nTests = nTests + 1;
            set testCases[nTests] = StatePreparationTestCase(3, [1.0986553; 0.359005; 0.465689; 0.467395; 0.419893; 0.118445; 0.123; 9.238], [1.0986553; 0.359005; 0.465689; -0.467395; 0.419893; 0.118445; 0.461883; 0.149609]);
            set nTests = nTests + 1;

            // Loop over tests
            for(idxTest in 0..nTests-1){
                let (nQubits, coefficientsAmplitude, coefficientsPhase) = testCases[idxTest];
                Message($"Test case {idxTest}");
                let nCoefficients = Length(coefficientsAmplitude);


                using(qubits = Qubit[nQubits]){
                    let qubitsBE = BigEndian(qubits);
                    mutable coefficients = new ComplexPolar[nCoefficients];
                    mutable coefficientsPositive = new Double[nCoefficients];
                    for(idxCoeff in 0..nCoefficients-1){
                        set coefficients[idxCoeff] = ComplexPolar(coefficientsAmplitude[idxCoeff], coefficientsPhase[idxCoeff]);
                        set coefficientsPositive[idxCoeff] = coefficientsAmplitude[idxCoeff];
                    }
                    let normalizedCoefficients = PNormalize(2.0, coefficientsAmplitude);

                    // Test probability and phases of arbitrary superposition
                    let opComplex = StatePreparationComplexCoefficients(coefficients);
                    let opReal = StatePreparationPositiveCoefficients(coefficientsPositive);

                    using(control = Qubit[1]){
                        // Test probability
                        H(control[0]);
                        (Controlled opComplex)(control, qubitsBE);
                        X(control[0]);
                        (Controlled opReal)(control, qubitsBE);
                        X(control[0]);
                        for(idxCoeff in 0..(nCoefficients-1)){
                            let amp = normalizedCoefficients[idxCoeff];
                            let prob = amp * amp;
                            AssertProbIntBE(idxCoeff, prob, qubitsBE, tolerance);
                        }
                        ResetAll(control);
                        ResetAll(qubits);
                        // Test phase
                        for(repeats in 0..nCoefficients/2){
                            H(control[0]);
                            (Controlled opComplex)(control, qubitsBE);
                            X(control[0]);
                            (Controlled opReal)(control, qubitsBE);
                            X(control[0]);
                            let indexMeasuredInteger = MeasureIntegerBE(qubitsBE);
                            let phase = coefficientsPhase[indexMeasuredInteger];
                            Message($"StatePreparationComplexCoefficientsTest: expected phase = {phase}.");
                            AssertPhase(-0.5 * phase, control[0], tolerance);
                            ResetAll(control);
                            ResetAll(qubits);
                        }
                    }
                }
            }
        }
    }

}
