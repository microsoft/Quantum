// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Chemistry.Samples.Hubbard {    
    open Microsoft.Quantum.Intrinsic;
	open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Chemistry.JordanWigner;
	open Microsoft.Quantum.Simulation;
    
    
    //////////////////////////////////////////////////////////////////////////
    // Using Trotterization //////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    
    /// # Summary
    /// We define an initial state of the Hamiltonian here.
    operation HubbardHalfFillingStatePrep (nFilling : Int, qubits : Qubit[]) : Unit {
        ApplyToEachCA(X, qubits[0..(nFilling / 2 - 1)]);
    }
    
    
    /// # Summary
    /// We can now use Canon's phase estimation algorithms to
    /// learn the ground state energy using the above simulation.
    operation GetEnergy (qSharpData : JordanWignerEncodingData, nBitsPrecision : Int, trotterStepSize : Double) : (Double, Double) {
        
        let (nSpinOrbitals, data, notUsedInThisSample, energyShift) = qSharpData!;
        
        // We use a Product formula, also known as `Trotterization` to
        // simulate the Hamiltonian.
        let trotterOrder = 1;
        let (nQubits, (rescaleFactor, oracle)) = TrotterStepOracle(qSharpData, trotterStepSize, trotterOrder);
        let statePrep = HubbardHalfFillingStatePrep(nQubits, _);
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
        let estPhase = EstimateEnergy(nQubits, statePrep, oracle, phaseEstAlgorithm);
        let estEnergy = estPhase / trotterStepSize + energyShift;
        return (estPhase, estEnergy);
    }
    
}


