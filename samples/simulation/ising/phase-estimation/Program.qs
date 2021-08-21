// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Ising {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation RunPhaseEstimation() : Unit {
        // Each site of the Ising model is simulated using a single qubit.
        let nSites = 9;

        // This coefficient is the initial coupling to the transverse field.
        let hXInitial = 1.0;

        // This coefficient is the final coupling to the transverse field.
        let hXFinal = 0.0;

        // This coefficient is the final coupling between sites.
        let jFinal = 1.0;

        // This is how long we take to sweep over the schedule parameter.
        let adiabaticTime = 10.0;

        // As we are using a Trotter–Suzuki decomposition as our simulation algorithm, we will need
        // to pick a timestep for the simulation, and the order of the integrator. The optimal
        // timestep needs to be determined empirically, and we find that the following choice works
        // well enough.
        let trotterStepSize = 0.1;
        let trotterOrder = 2;

        // The phase estimation algorithm requires us to choose the duration of time-evolution in
        // the oracle it calls, and the bits of precision to which we estimate the phase. Note that
        // the error of the energy estimate is typically rescaled by 1 / `qpeStepSize`.
        let qpeStepSize = 0.1;
        let nBitsPrecision = 5;

        // For diagnostic purposes, before we proceed to the next step, we'll print out a
        // description of the parameters we just defined.
        Message(
            "Ising model parameters:\n" +
            $"\t{nSites} sites\n" +
            $"\t{hXInitial} initial transverse field coefficient\n" +
            $"\t{hXFinal} final transverse field coefficient\n" +
            $"\t{jFinal} final two-site coupling coefficient\n" +
            $"\t{adiabaticTime} time-interval of interpolation\n" +
            $"\t{trotterStepSize} simulation time step \n" +
            $"\t{trotterOrder} order of integrator \n" +
            $"\t{qpeStepSize} phase estimation oracle simulation time step \n" +
            $"\t{nBitsPrecision} phase estimation bits of precision\n"
        );

        // Let us now prepare an approximate ground state of the Ising model and estimate its ground
        // state energy. This procedure is probabilistic as the quantum state obtained at the end of
        // adiabatic evolution has overlap with the ground state that is less that one. Thus we
        // repeat several times. In this case, we also know that the ground state has all spins
        // pointing in the same direction, so we print the results of measuring each site after
        // perform phase estimation to check if we were close.

        Message(
            "Adiabatic state preparation of the Ising model with uniform couplings followed by " +
            "phase estimation and then measurement of sites."
        );

        // Theoretical prediction of ground state energy when hXFinal is 0.
        let energyTheory = - jFinal * IntAsDouble(nSites - 1);

        for idx in 0 .. 9 {
            let (energyEst, measuredState) = EstimateIsingEnergy(
                nSites, hXInitial, hXFinal, jFinal,
                adiabaticTime, trotterStepSize, trotterOrder,
                qpeStepSize, nBitsPrecision
            );

            Message($"State: {measuredState} Energy estimate: {energyEst} vs Theory: {energyTheory}.");
        }

        Message("\nSame procedure, but using the built-in function.");
        for idx in 0 .. 9 {
            let phaseEst = EstimateIsingEnergyUsingBuiltin(
                nSites, hXInitial, hXFinal, jFinal,
                adiabaticTime, trotterStepSize, trotterOrder,
                qpeStepSize, nBitsPrecision
            );

            Message($"Energy estimate: {phaseEst} vs Theory: {energyTheory}.");
        }
    }
}
