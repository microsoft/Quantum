// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Chemistry.Samples.FermionicSwapHubbard {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Chemistry.JordanWigner;
    open Microsoft.Quantum.Simulation;

    open FermionicSwap;


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
    operation GetEnergy (nQubits : Int, swapNetwork : (Int,Int)[][], localEvolutions : JWOptimizedHTerms[][], nBitsPrecision : Int, trotterStepSize : Double) : (Double, Double) {
        // old line
        // let (nSpinOrbitals, data, notUsedInThisSample, energyShift) = localEvolutions!;
        let energyShift=0.;

        // We use a Product formula, also known as `Trotterization` to
        // simulate the Hamiltonian.
        // old lines:
        // let trotterOrder = 1;
        // let (nQubits, (rescaleFactor, oracle)) = TrotterStepOracle(qSharpData, trotterStepSize, trotterOrder);
        let generator = FermionicSwapEvolutionGenerator(swapNetwork, localEvolutions);
        let oracle = FermionicSwapEvolveUnderGenerator(generator, trotterStepSize, 2.*trotterStepSize, _);
        let statePrep = HubbardHalfFillingStatePrep(nQubits, _);
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
        let estPhase = EstimateEnergy(nQubits, statePrep, oracle, phaseEstAlgorithm);
        let estEnergy = estPhase / trotterStepSize + energyShift;
        return (estPhase, estEnergy);
    }

}
