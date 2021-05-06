namespace Microsoft.Quantum.Chemistry.Trotterization {
    open Microsoft.Quantum.Core;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Chemistry;
    open Microsoft.Quantum.Chemistry.JordanWigner;  
    open Microsoft.Quantum.Simulation;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;

    operation GetEnergyByTrotterization (
        JWEncodedData: JordanWignerEncodingData,
        nBitsPrecision : Int, 
        trotterStepSize : Double, 
        trotterOrder : Int
    ) : (Double, Double) {

        let (nSpinOrbitals, fermionTermData, inputState, energyOffset) = JWEncodedData!;
        let (nQubits, (rescaleFactor, oracle)) = TrotterStepOracle(JWEncodedData, trotterStepSize, trotterOrder);
        let statePrep = PrepareTrialState(inputState, _);
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
        let estPhase = EstimateEnergy(nQubits, statePrep, oracle, phaseEstAlgorithm);
        let estEnergy = estPhase * rescaleFactor + energyOffset;

        return (estPhase, estEnergy);
    }
}
