namespace Microsoft.Quantum.Samples.Chemistry.VQE.EstimateEnergy {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Samples.Chemistry.VQE.StatePreparation;


    operation SumTermExpectation(inputState: (Int, ((Double, Double), Int[])[]), ops : Pauli[][], coeffs : Double[], nQubits : Int,  nSamples : Int) : Double {
        mutable jwTermEnergy = 0.;
	    for ((coeff, op) in Zip(coeffs, ops)) {
            // Only perform computation if the coefficient is significant enough
            if (AbsD(coeff) >= 1e-10) {
                // Compute expectation value using the fast frequency estimator, add contribution to Jordan-Wigner term energy
                let termExpectation = TermExpectation(inputState, op, nQubits, nSamples);
                set jwTermEnergy += (2. * termExpectation - 1.) * coeff;
            }
        }

        return jwTermEnergy;
    }

    operation TermExpectation(
        inputState: (Int, ((Double, Double), Int[])[]),
        measOp: Pauli[],
        nQubits: Int,
        nSamples: Int
    ) : Double {
        mutable nUp = 0;
        for (idxMeasurement in 0 .. nSamples - 1) {
            using (register = Qubit[nQubits]) {
                PrepareTrialState(inputState, register);
                // inputStateUnitary(register);
                let result = Measure(measOp, register);
                if (result == Zero) {
                    set nUp += 1;
                }
                ApplyToEach(Reset, register);
            }
        }
        return IntAsDouble(nUp) / IntAsDouble(nSamples);
    }
}
