// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Chemistry.Samples {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Research.Chemistry;
    open Microsoft.Quantum.Chemistry.JordanWigner;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Simulation;

    //////////////////////////////////////////////////////////////////////////
    // Using Trotterization //////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// We can now use Canon's phase estimation algorithms to
    /// learn the ground state energy using the above simulation.
    operation TrotterEstimateEnergy (qSharpData: JordanWignerEncodingData, nBitsPrecision : Int, trotterStepSize : Double) : (Double, Double) {

        let (nSpinOrbitals, data, statePrepData, energyShift) = qSharpData!;

        // Order of integrator
        let trotterOrder = 1;
        let (nQubits, (rescaleFactor, oracle)) = TrotterStepOracle(qSharpData, trotterStepSize, trotterOrder);

        // Prepare ProductState
        let statePrep =  PrepareTrialState(statePrepData, _);
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
        let estPhase = EstimateEnergy(nQubits, statePrep, oracle, phaseEstAlgorithm);
        let estEnergy = estPhase * rescaleFactor + energyShift;
        return (estPhase, estEnergy);
    }

    //////////////////////////////////////////////////////////////////////////
    // Using optimized Trotterization circuit ////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    
    /// # Summary
    /// We can now use Canon's phase estimation algorithms to
    /// learn the ground state energy using the above simulation.
    operation OptimizedTrotterEstimateEnergy (qSharpData: JordanWignerEncodingData, nBitsPrecision : Int, trotterStepSize : Double) : (Double, Double) {
        
        let (nSpinOrbitals, data, statePrepData, energyShift) = qSharpData!;
        
        // Order of integrator
        let trotterOrder = 1;
        let (nQubits, (rescaleFactor, oracle)) = OptimizedTrotterStepOracle(qSharpData, trotterStepSize, trotterOrder);
        
        // Prepare ProductState
        let statePrep =  PrepareTrialState(statePrepData, _);
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
        let estPhase = EstimateEnergy(nQubits, statePrep, oracle, phaseEstAlgorithm);
        let estEnergy = estPhase * rescaleFactor + energyShift;
        return (estPhase, estEnergy);
    }
    
    
    //////////////////////////////////////////////////////////////////////////
    // Using Qubitization ////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    
    
    
    // # Summary
    // Instead of implemeting real-time evolution e^{iHt} with a Product formula,
    // we may encode e^{isin^{-1}{H}} in a quantum walk created using
    // the `Qubitization` procedure.
    
    /// # Summary
    /// We can now use Canon's phase estimation algorithms to
    /// learn the ground state energy using the above simulation.
    operation QubitizationEstimateEnergy (qSharpData: JordanWignerEncodingData, nBitsPrecision : Int) : (Double, Double) {
        
        let (nSpinOrbitals, data, statePrepData, energyShift) = qSharpData!;
        let (nQubits, (l1Norm, oracle)) = QubitizationOracle(qSharpData);
        let statePrep =  PrepareTrialState(statePrepData, _);
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
        let estPhase = EstimateEnergy(nQubits, statePrep, oracle, phaseEstAlgorithm);
        
        // Note that the quantum walk applies e^{isin^{-1}{H/oneNorm}}, in contrast to
        // real-time evolution e^{iHt} by a Product formula.
        
        // Thus We obtain the energy estimate by applying Sin(.) to the phase estimate
        // then rescaling by the coefficient one-norm of the Hamiltonian.
        // We also add the constant energy offset to the estimated energy.
        let estEnergy = Sin(estPhase) * l1Norm + energyShift;
        
        // We return both the estimated phase, and the estimated energy.
        return (estPhase, estEnergy);
    }
    
}


