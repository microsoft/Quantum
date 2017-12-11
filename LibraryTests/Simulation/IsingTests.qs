// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.Ising {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Canon;


    /// Test Ising model anti-ferromagnetic simulation by ZZ correlation function
    operation Ising1DAntiFerromagneticTest() : () {
        body {
            let nSites = 5;
            let adiabaticTime = 100.1;
            let trotterOrder = 1;
            let scheduleSteps = 100;
            let trotterStepSize = adiabaticTime / ToDouble(scheduleSteps);
            let hXamplitude = 1.123;
            let hXfinal = 0.0;
            let jCamplitude = -0.985;

            // Probabilities obtained from independent simulation
            let probX = [0.498979; 0.49967; 0.499805; 0.49967; 0.498979];
            let probZZ = [0.0000442226; 0.0000213399; 0.0000213399; 0.0000442226];
            using (qubits = Qubit[nSites]) {
                Ising1DStatePrep(qubits);
                (IsingAdiabaticEvolutionManual(nSites, hXamplitude, hXfinal, jCamplitude, adiabaticTime, trotterStepSize, trotterOrder))(qubits);

                for (idxQubit in 0..4) {
                    AssertProb([PauliX], [qubits[idxQubit]], One, probX[idxQubit], "IsingUniformAdiabaticEvolution Qubit X expectation incorrect",  1e-3);
                }
                for (idxQubit in 0..3) {
                    AssertProb([PauliZ; PauliZ], qubits[idxQubit..idxQubit+1], Zero, probZZ[idxQubit], "IsingUniformAdiabaticEvolution Qubit ZZ expectation incorrect",  1e-9);
                }

                ResetAll(qubits);
                Ising1DStatePrep(qubits);
                (IsingAdiabaticEvolutionManual(nSites, hXamplitude, hXfinal, jCamplitude, adiabaticTime, trotterStepSize, trotterOrder))(qubits);
                for (idxQubit in 0..4) {
                    AssertProb([PauliX], [qubits[idxQubit]], One, probX[idxQubit], "IsingAdiabaticEvolution_2 Qubit X expectation incorrect",  1e-3);
                }
                for (idxQubit in 0..3) {
                    AssertProb([PauliZ; PauliZ], qubits[idxQubit..idxQubit+1], Zero, probZZ[idxQubit], "IsingAdiabaticEvolution_2 Qubit ZZ expectation incorrect",  1e-9);
                }

                ResetAll(qubits);

            }
        }
    }

}
