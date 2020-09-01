// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.SimpleIsing {

    open Microsoft.Quantum.Arrays as Array;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation RunProgram () : Unit {
        
        // For this example, we'll consider a chain of twelve sites, each one of which
        // is simulated using a single qubit.
        let nSites = 12;

        // We'll sweep from the transverse to the final Hamiltonian in time t = 10.0,
        // where the units are implicitly fixed by the units of the Hamiltonian itself.
        let sweepTime = 10.0;

        // Ising coupling
        let J = 1.0;

        // Set the sign by parity of lattice site index
        let signByParity = false;

        // Order the lattice sites in a cycle instead of an open-ended chain
        let cycle = true;

        // All-to-all coupling
        let allToAll = false;

        // Create an array of site-to-site couplings
        // Here we use a chain with constant Ising coupling
        let couplings = GenerateCouplings(
            nSites, J, signByParity, cycle, allToAll);

        // Finally, we'll then decompose the time evolution down into small steps.
        // During each step, we'll perform each term in the Hamiltonian individually.
        // By the Trotter–Suzuki decomposition (also implemented in the canon), this
        // approximates the complete Hamiltonian for the entire sweep time.
        //
        // If we choose the evolution time carefully, we should prepare the ground
        // state of our final Hamiltonian (see the references in README.md for more
        // details).
        let timeStep = 0.1;

        // For diagnostic purposes, before we proceed to the next step, we'll print
        // out a description of the parameters we just defined.
        Message("Ising model ground state preparation:");
        Message($"    {nSites} sites");
        Message($"    {sweepTime} sweep time");
        Message($"    {timeStep} time step");

        // Now that we've defined everything we need, let's proceed to
        // actually call the operation. Since there's a finite chance of successfully
        // preparing the ground state, we will call it several times, 
        // reporting the magnetization after each attempt.

        for (idxAttempt in 1 .. 100)
        {
            let data = SimulateIsingEvolution(nSites, sweepTime, timeStep, couplings);
            // We convert each Result into a floating point number 
            // representing the observed spin and compute the magnetization.
            let magnetization = Array.Fold(AddMagnetization, 0.0, data); 
            Message($"Magnetization observed in attempt {idxAttempt}: {magnetization}");
        }
    }
}
