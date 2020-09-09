namespace Microsoft.Quantum.Samples.Chemistry.VariationalQuantumEigensolver {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Samples.Chemistry.VQE.EstimateEnergy;
    open Microsoft.Quantum.Samples.Chemistry.VQE.StatePreparation;
    open Microsoft.Quantum.Samples.Chemistry.VQE.Utils;

    operation EstimateEnergy(
        nQubits : Int,
        hamiltonianTermList : (
                (Int[], Double[])[], 
                (Int[], Double[])[], 
                (Int[], Double[])[], 
                (Int[], Double[])[]
            ),
        inputState : (Int, ((Double, Double), Int[])[]),
        energyOffset : Double,
        nSamples: Int
    ) : Double {
        mutable energy = 0.0;
        let (inputStateType, inputStateTerms) = inputState;
        let (ZData, ZZData, PQandPQQRData, h0123Data) = hamiltonianTermList;
        let hamiltonianTermArray = [ZData, ZZData, PQandPQQRData, h0123Data];
        let nTerms = Length(ZData) + Length(ZZData) + Length(PQandPQQRData) + Length(h0123Data);

        for (termType in 0..Length(hamiltonianTermArray)-1) {
            let hamiltonianTerms = hamiltonianTermArray[termType];
            for (hamiltonianTerm in hamiltonianTerms) {
                let (qubitIndices, coefficient) = hamiltonianTerm;
                let measOps = VQEMeasurementOperators(nQubits, qubitIndices, termType);
                let coefficients = ExpandedCoefficients(coefficient, termType);
                let jwTermEnergy = SumTermExpectation(inputState, measOps, coefficients, nQubits, nSamples);
                set energy += jwTermEnergy;
            }
        }

        return energy;
    }
}
