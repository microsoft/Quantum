// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;

    operation ChoiStateTest() : () {
        body {
            using (register = Qubit[2]) {
                PrepareChoiStateCA(NoOp, [register[0]], [register[1]]);
                // As usual, the same confusion about {+1, -1} and {0, 1}
                // labeling bites us here.
                Assert([PauliX; PauliX], register, Zero, "XX");
                Assert([PauliZ; PauliZ], register, Zero, "ZZ");

                ResetAll(register);
            }
        }
    }

    operation EstimateFrequencyTest () : () {
        body {
            let freq = EstimateFrequency(
                ApplyToEach(H, _),
                MeasureAllZ,
                1,
                1000
            );

            AssertAlmostEqualTol(freq, 0.5, 0.1);
        }
    }

    operation _RobustPhaseEstimationTestOp(phase: Double, power: Int, qubits : Qubit[]) : (){
        body {
            //Rz(- 2.0* phase * ToDouble(power), qubits[0])
            Exp([PauliZ], phase * ToDouble(power), qubits);
            //Exp([PauliI], phase * ToDouble(power), qubits);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    operation RobustPhaseEstimationDemoImpl(phaseSet : Double, bitsPrecision: Int) : Double{
        body {
            let op = DiscreteOracle(_RobustPhaseEstimationTestOp(phaseSet, _, _));
            mutable phaseEst = ToDouble(0);
            using (q = Qubit[1]) {
                set phaseEst = RobustPhaseEstimation(bitsPrecision, op, q);
                ResetAll(q);
            }
            return phaseEst;
        }
    }

    // Probabilistic test. Might fail occasionally
    operation RobustPhaseEstimationTest() : () {
        body {

            let bitsPrecision = 10;

            for (idxTest in 0..9) {
                let phaseSet = 2.0 * PI() * ToDouble(idxTest - 5) / 12.0;
                let phaseEst = RobustPhaseEstimationDemoImpl(phaseSet, bitsPrecision);
                AssertAlmostEqualTol(phaseEst, phaseSet, 1e-2);
            }
        }
    }

    operation PrepareQubitTest() : () {
        body {
            using (register = Qubit[1]) {
                let qubit = register[0];
                let bases = [PauliI; PauliX; PauliY; PauliZ];

                for (idxBasis in 0..Length(bases) - 1) {
                    let basis = bases[idxBasis];
                    PrepareQubit(basis, qubit);
                    Assert([basis], register, Zero, $"Did not prepare in {basis} correctly.");
                    Reset(qubit);
                }
            }
        }
    }

    operation SingleQubitProcessTomographyMeasurementTest() : () {
        body {
            AssertResultEqual(SingleQubitProcessTomographyMeasurement(PauliI, PauliI, H), Zero, "Failed at ⟪I | H | I⟫.");
            AssertResultEqual(SingleQubitProcessTomographyMeasurement(PauliX, PauliI, H), Zero, "Failed at ⟪I | H | X⟫.");
            AssertResultEqual(SingleQubitProcessTomographyMeasurement(PauliY, PauliI, H), Zero, "Failed at ⟪I | H | Y⟫.");
            AssertResultEqual(SingleQubitProcessTomographyMeasurement(PauliZ, PauliI, H), Zero, "Failed at ⟪I | H | Z⟫.");

            AssertResultEqual(SingleQubitProcessTomographyMeasurement(PauliX, PauliZ, H), Zero, "Failed at ⟪Z | H | X⟫.");
            AssertResultEqual(SingleQubitProcessTomographyMeasurement(PauliY, PauliY, H), One,  "Failed at -⟪Y | H | Y⟫.");
            AssertResultEqual(SingleQubitProcessTomographyMeasurement(PauliX, PauliZ, H), Zero, "Failed at ⟪Z | H | X⟫.");
        }
    }

}
