namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Chemistry.JordanWigner;    
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Simulation;

    operation TrotterEstimateEnergy (qSharpData: JordanWignerEncodingData, nBitsPrecision : Int, trotterStepSize : Double) : (Double, Double) {
        
        let (nSpinOrbitals, data, statePrepData, energyShift) = qSharpData!;
        
        // Order of integrator
        let trotterOrder = 1;
        let (nQubits, (rescaleFactor, oracle)) = TrotterStepOracle(qSharpData, trotterStepSize, trotterOrder);
        
        // Prepare ProductState
        let statePrep =  PrepareTrialState(statePrepData, _);
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
        let estPhase = EstimateEnergyWithAdiabaticEvolution(nQubits, statePrep, NoOp<Qubit[]>, oracle, phaseEstAlgorithm);
        let estEnergy = estPhase * rescaleFactor + energyShift;
        return (estPhase, estEnergy);
    }
}