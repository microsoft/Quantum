// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Ising {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation RunTrotterSuzuki() : Unit {
        // For this example, we'll consider a chain of five sites, each one of which is simulated
        // using a single qubit.
        let nSites = 7;

        // We'll evolve for times ranging from t = 0.1 to t = 1.0, in steps of 0.1 where the units
        // are implicitly fixed by the units of the Hamiltonian itself.
        let nTimeSteps = 10;
        let deltaTime = 0.1;

        // We choose the order of the Trotter–Suzuki integrator.
        let trotterOrder = 2;

        // We should choose the step size of each Trotter step to be small.
        let timeStep = 0.1;

        // We will perform a number of repeats to collect statistics
        let repeats = 100;

        // For diagnostic purposes, before we proceed to the next step, we'll print out a
        // description of the parameters we just defined.
        Message(
            "Ising model spin excitation:\n" +
            $"\t{nSites} sites\n" +
            $"\t{IntAsDouble(nTimeSteps) * deltaTime} max simulation time\n" +
            $"\t{deltaTime} time increment\n" +
            $"\t{timeStep} time step\n"
        );

        // Now that we've defined everything we need, let's proceed to actually call the simulator.
        // As we only receive a single bit of data each time on a single-site measurement, we repeat
        // a number of times to collect statistics.
        for idxTimeStep in 0 .. nTimeSteps {
            let time = IntAsDouble(idxTimeStep) * deltaTime;

            // We initialize an array that stores counts of measurement result for each site.
            mutable counts = [0.0, size = nSites];

            for idxAttempt in 0 .. repeats - 1 {
                let results = Ising1DExcitationCorrelation(nSites, time, trotterOrder, timeStep);

                // We can now compute the magnetization entirely in C# code, since data is
                // an array of the classical measurement results observed back from our simulation.
                for idxSite in 0 .. nSites - 1 {
                    set counts w/= idxSite <- counts[idxSite] + (results[idxSite] == One ? 1.0 | -1.0);
                }
            }

            Message($"Evolution for {time} time.\tSum of magnetization: {counts}\tafter {repeats} repeats.");
        }
    }
}
