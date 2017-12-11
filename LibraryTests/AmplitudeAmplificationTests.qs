// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;

    
	///Here we consider the smallest example of amplitude amplification
	///Suppose we have a single-qubit oracle that prepares the state
	/// O |0> = \lambda |1> + \sqrt{1-|\lambda|^2} |0>
	/// The goal is to amplify the |1> state
	/// We can do this either by synthesizing the reflection about the start and target states ourselves,
	/// We can also do it by passing the oracle for state preparation
 
	operation ExampleStatePrepImpl( lambda : Double, idxFlagQubit : Int , qubitStart : Qubit[] ) : ()
	{
		body
		{
			let rotAngle = 2.0 * ArcSin(lambda);
			Ry(rotAngle, qubitStart[idxFlagQubit]);
		}

		adjoint auto
		controlled auto
		adjoint controlled auto
 
	}
	function ExampleStatePrep( lambda : Double ) : StateOracle
	{
		return StateOracle( ExampleStatePrepImpl (lambda, _, _) );
	}

	/// In this minimal example, there are no system qubits, only a single flag qubit. 
	/// ExampleStatePrep is already of type  StateOracle, so we call
	/// AmpAmpByOracle(iterations: Int, stateOracle : StateOracle, idxFlagQubit : Int startQubits: Qubit[]) : ()
    operation AmpAmpByOracleTest() : ()
	{
		body {

			using(qubits = Qubit[1]){
				ResetAll(qubits);
				for (nIterations in 0..5) {


					for (idx in 1..20) {
						let lambda = ToDouble(idx) / 20.0;
                        let rotAngle = ArcSin(lambda);
						let idxFlag = 0;
						let startQubits = qubits;

						let stateOracle = ExampleStatePrep(lambda);

						(AmpAmpByOracle(nIterations, stateOracle, idxFlag))(startQubits);

						let successAmplitude = Sin( ToDouble(2 * nIterations + 1) * rotAngle );
						let successProbability = successAmplitude * successAmplitude;
						AssertProb([PauliZ], [startQubits[idxFlag]], One, successProbability, "Error: Success probability does not match theory", 1e-10);

						ResetAll(qubits);
					}
				}
			}
		}
	}

	operation AmpAmpObliviousByOraclePhasesTest() : ()
	{
		body {

			using(qubits = Qubit[1]) {
				ResetAll(qubits);

				for (nIterations in 0..5) {
					let phases = AmpAmpPhasesStandard(nIterations);
					for (idx in 0..20) {
						let rotAngle = ToDouble(idx) * PI() / 20.0;
						let idxFlag = 0;
						let ancillaRegister = qubits;
						let systemRegister = new Qubit[0];

						let ancillaOracle = DeterministicStateOracle(Exp([PauliY], rotAngle * 0.5, _));
						let signalOracle = ObliviousOracle(NoOp2(_,_));

						(AmpAmpObliviousByOraclePhases(phases, ancillaOracle, signalOracle, idxFlag))(ancillaRegister, systemRegister);

						let successAmplitude = Sin( ToDouble(2 * nIterations + 1) * rotAngle * 0.5 );
						let successProbability = successAmplitude * successAmplitude;
						AssertProb([PauliZ], [ancillaRegister[idxFlag]], One, successProbability, "Error: Success probability does not match theory", 1e-10);

						ResetAll(qubits);
					}
				}
			}
		}
	}

	operation AmpAmpTargetStateReflectionOracleTest() : ()
	{
		body {
			using (qubits = Qubit[1]) {
				ResetAll(qubits);
				for (idx in 0..20) {
					let rotangle = ToDouble(idx) * PI() / 20.0;
					let targetStateReflection = TargetStateReflectionOracle(0);

					let success = Cos(0.5 * rotangle) * Cos(0.5 * rotangle);

					H(qubits[0]);
					targetStateReflection(rotangle,qubits);
					AssertProb([PauliX], qubits, Zero, success, "Error: Success probability does not match theory", 1e-10);
					ResetAll(qubits);
				}
			}
		}
	}

}
