// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Chemistry.QPE {
    open Microsoft.Quantum.Core;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Chemistry;
    open Microsoft.Quantum.Chemistry.JordanWigner;  
    open Microsoft.Quantum.Simulation;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;

    /// # Summary
    /// Get the molecule energy using Quantum Phase Estimation.
    ///
    /// # Input
    /// ## JWEncodedData
    /// Jordan-Wigner encoded data.
    /// ## nBitsPrecision
    /// Number of bits of precision.
    /// ## trotterStepSize
    /// Trotter step size.
    /// ## trotterOrder
    /// The Trotter order to use.
    ///
    /// # Output
    /// Returns estimated energy.
    operation GetEnergyQPE (
        JWEncodedData: JordanWignerEncodingData,
        nBitsPrecision : Int, 
        trotterStepSize : Double, 
        trotterOrder : Int
    ) : Double {

        let (_, _, inputState, energyOffset) = JWEncodedData!;
        let (nQubits, (rescaleFactor, oracle)) = TrotterStepOracle(JWEncodedData, trotterStepSize, trotterOrder);
        let statePrep = PrepareTrialState(inputState, _);
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
        let estPhase = EstimateEnergy(nQubits, statePrep, oracle, phaseEstAlgorithm);
        let estEnergy = estPhase * rescaleFactor + energyOffset;

        return estEnergy;
    }
}
