// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Chemistry.Samples.Hydrogen {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Chemistry.JordanWigner;
    open Microsoft.Quantum.Simulation;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;

    // We now use the Q# component of the chemistry library to obtain
    // quantum operations that implement real-time evolution by
    // the chemistry Hamiltonian. Below, we consider two examples.
    // - Trotter simulation algorithm
    // - Qubitization simulation algorithm

    // These operations are invoked as oracles in the quantum phase estimation
    // algorithm to extract energy estimates of various eigenstate of the
    // Hamiltonian.

    // The returned energy estimate is chosen probabilistically, depending on
    // the overlap of the initial trial state. By default, we greedily
    // fill spin-orbitals to minimize the diagonal component of the one-electron
    // energies.

    //////////////////////////////////////////////////////////////////////////
    // Using Trotterization //////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // We can now use Canon's phase estimation algorithms to
    // learn the ground state energy using the above simulation.
    operation GetEnergyByTrotterization (qSharpData : JordanWignerEncodingData, nBitsPrecision : Int, trotterStepSize : Double, trotterOrder : Int) : (Double, Double) {

        // The data describing the Hamiltonian for all these steps is contained in
        // `qSharpData`
        let (nSpinOrbitals, fermionTermData, statePrepData, energyOffset) = qSharpData!;

        // We use a Product formula, also known as `Trotterization` to
        // simulate the Hamiltonian.
        let (nQubits, (rescaleFactor, oracle)) = TrotterStepOracle(qSharpData, trotterStepSize, trotterOrder);

        // The operation that creates the trial state is defined below.
        // By default, greedy filling of spin-orbitals is used.
        let statePrep = PrepareTrialState(statePrepData, _);

        // We use the Robust Phase Estimation algorithm
        // of Kimmel, Low and Yoder.
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);

        // This runs the quantum algorithm and returns a phase estimate.
        let estPhase = EstimateEnergy(nQubits, statePrep, oracle, phaseEstAlgorithm);

        // We obtain the energy estimate by rescaling the phase estimate
        // with the trotterStepSize. We also add the constant energy offset
        // to the estimated energy.
        let estEnergy = estPhase * rescaleFactor + energyOffset;

        // We return both the estimated phase, and the estimated energy.
        return (estPhase, estEnergy);
    }


    //////////////////////////////////////////////////////////////////////////
    // Using Qubitization ////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // The following is identical to the approach above using Trotterization,
    // except that we replace the oracle with a quantum walk created by the
    // qubitization procedure. This results in a more accurate simulation,
    // but at the cost of larger qubit overhead.
    operation GetEnergyByQubitization (qSharpData : JordanWignerEncodingData, nBitsPrecision : Int) : (Double, Double) {

        // The data describing the Hamiltonian for all these steps is contained in
        // `qSharpData`
        let (nSpinOrbitals, fermionTermData, statePrepData, energyOffset) = qSharpData!;

        // The parameters required by Qubitization is contained in this
        // convenience function.
        let (nQubits, (oneNorm, oracle)) = QubitizationOracle(qSharpData);

        // The operation that creates the trial state is defined below.
        // By default, greedy filling of spin-orbitals is used.
        let statePrep = PrepareTrialState(statePrepData, _);

        // We use the Robust Phase Estimation algorithm
        // of Kimmel, Low and Yoder.
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);

        // This runs the quantum algorithm and returns a phase estimate.
        let estPhase = EstimateEnergy(nQubits, statePrep, oracle, phaseEstAlgorithm);

        // Note that the quantum walk applies e^{isin^{-1}{H/oneNorm}}, in contrast to
        // real-time evolution e^{iHt} by a Product formula.

        // Thus We obtain the energy estimate by applying Sin(.) to the phase estimate
        // then rescaling by the coefficient one-norm of the Hamiltonian.
        // We also add the constant energy offset to the estimated energy.
        let estEnergy = Sin(estPhase) * oneNorm + energyOffset;

        // We return both the estimated phase, and the estimated energy.
        return (estPhase, estEnergy);
    }

}

