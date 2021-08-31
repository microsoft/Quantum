// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Ising {
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation RunAdiabaticEvolution() : Unit {
        // Each site of the Ising model is simulated using a single qubit. 
        let nSites = 9;

        // In all the following, we use this coefficient for coupling to the transverse field.
        let hxCoeff = 1.0;

        // For now, we also use this coefficient for coupling between sites.
        mutable jCCoeff = 1.0;

        // As we are using a Trotter–Suzuki decomposition as our simulation algorithm, we will need
        // to pick a timestep for the simulation, and the order of the integrator. The optimal
        // timestep needs to be determined empirically, and we find that the following choice works
        // well enough.
        let trotterStepSize = 0.1;
        let trotterOrder = 2;

        // Let us now simulate time-evolution by interpolating between the initial Hamiltonian with
        // the |+〉 product state as the ground state, and the target Hamiltonian. For the uniform
        // Ising model, the ground state of the target Hamiltonian should have all spins pointing in
        // the same direction. If we interpolate between these Hamiltonians slowly enough, the
        // initial ground state will continuously deform into the ground state of the target
        // Hamiltonian

        // Let us consider the situation where we interpolate between these Hamiltonians too
        // quickly.
        mutable adiabaticTime = 0.1;

        // For diagnostic purposes, before we proceed to the next step, we'll print out a
        // description of the parameters we just defined.
        Message(
            "Ising model parameters:\n" +
            $"\t{nSites} sites\n" +
            $"\t{hxCoeff} transverse field coefficient\n" +
            $"\t{jCCoeff} two-site coupling coefficient\n" +
            $"\t{adiabaticTime} time-interval of interpolation\n" +
            $"\t{trotterStepSize} simulation time step \n" +
            $"\t{trotterOrder} order of integrator\n"
        );

        Message(
            "Let us consider the results of fast non-adiabatic evolution from the transverse " +
            "Hamiltonian to the coupling Hamiltonian. Observe that the zeros and one occur almost " +
            "randomly."
        );

        // We measure each site after this time-dependent simulation, and repeat 10 times as the
        // output is probabilistic.
        for rep in 0 .. 9 {
            let results = Ising1DAdiabaticAndMeasureManual(
                nSites, hxCoeff, jCCoeff, adiabaticTime, trotterStepSize, trotterOrder
            );

            Message($"State: {results}");
        }

        // Let now interpolate between these Hamiltonians more slowly.
        set adiabaticTime = 10.0;
        Message(
            "\nIsing model parameters:\n" +
            $"\t{nSites} sites\n" +
            $"\t{hxCoeff} transverse field coefficient\n" +
            $"\t{jCCoeff} two-site coupling coefficient\n" +
            $"\t{adiabaticTime} time-interval of interpolation\n" +
            $"\t{trotterStepSize} simulation time step \n" +
            $"\t{trotterOrder} order of integrator\n"
        );

        Message(
            "Let us now slow down the evolution. Observe that there is now a stronger correlation " +
            "in the measurement results on neighbouring sites."
        );

        for rep in 0 .. 9 {
            let results = Ising1DAdiabaticAndMeasureManual(
                nSites, hxCoeff, jCCoeff, adiabaticTime, trotterStepSize, trotterOrder
            );

            Message($"State: {results}");
        }

        // We may also study anti-ferromagnetic coupling by changing the sign of jCCoeff.
        set jCCoeff = -1.0;
        Message(
            "\nIsing model parameters:\n" +
            $"\t{nSites} sites\n" +
            $"\t{hxCoeff} transverse field coefficient\n" +
            $"\t{jCCoeff} two-site coupling coefficient\n" +
            $"\t{adiabaticTime} time-interval of interpolation\n" +
            $"\t{trotterStepSize} simulation time step \n" +
            $"\t{trotterOrder} order of integrator\n"
        );

        Message(
            "Observe that there is now a strong anti-correlation in the measurement results on " +
            "neighbouring sites."
        );

        // Let us use this opportunity to test the adiabatic evolution as written using more library
        // functions.
        for rep in 0 .. 9 {
            let results = Ising1DAdiabaticAndMeasureBuiltIn(
                nSites, hxCoeff, jCCoeff, adiabaticTime, trotterStepSize, trotterOrder
            );

            Message($"State: {results}");
        }
    }
}
