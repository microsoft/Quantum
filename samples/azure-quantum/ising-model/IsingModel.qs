// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // In this example, we will show how to simulate the time evolution of
    // an Ising model under a transverse field,
    //
    //     H(s) ≔ s [- J Σ'ᵢⱼ Zᵢ Zⱼ - hz Σᵢ Zᵢ] - (1 - s) hx Σᵢ Xᵢ
    //
    // where the primed summation Σ' is taken only over nearest-neighbors,
    // and where s is a parameter in the interval [0, 1] that controls the
    // sweep to the final Hamiltonian.

    // We do so by first defining an operation which will rotate a pair of
    // qubits (q₁, q₂) by an angle φ around ZZ,
    //
    //    U(φ) = e^{i φ Z₁ Z₂}.
    //
    // In terms of the intrinsic gates defined by Q#, we can write
    // this by conjugating an Rz rotation by CNOTs. Later, we will see
    // how this can be written more compactly using operations and functions
    // from the canon, and how to use other intrinsic operations to
    // exponentiate arbitrary Pauli operators.

    /// # Summary
    /// Given two qubits and a rotation angle, rotates the given
    /// qubits about ZZ.
    ///
    /// # Input
    /// ## phi
    /// Angle by which to rotate the given qubits.
    /// ## q1
    /// The first qubit to be rotated.
    /// ## q2
    /// The second qubit to be rotated.
    operation ApplyZZ(phi : Double, q1 : Qubit, q2 : Qubit) : Unit is Adj + Ctl {
        ApplyWithCA(CNOT(q1, _), Rz(-2.0 * phi, _), q2);
    }

    // With this operation in place, we can now decompose evolution
    // under the full Hamiltonian H given above using the Trotter–Suzuki
    // decomposition. For simplicity, we'll use the first-order Trotter–Suzuki
    // decomposition; higher orders can be written easily using the flow control
    // and generator representation operations provided with the canon.

    /// # Summary
    /// Sweeps from an transverse field to an Ising model using a linear
    /// schedule.
    ///
    /// # Input
    /// ## nSites
    /// Number of spins in the Ising model under consideration.
    /// ## time
    /// Overall evolution time to simulate.
    /// ## dt
    /// The length of time for each timestep in the simulation.
    ///
    /// # Output
    /// The results of Z measurements on each qubit.
    ///
    /// # Remarks
    /// This operation allocates qubits internally to use in simulation,
    /// such that it is straightforward to call this operation from
    /// conventional .NET code.
    @EntryPoint()
    operation SimulateIsingEvolution(nSites : Int, time : Double, dt : Double) : Result[] {

        // Next, we use the using keyword to declare that the following
        // block needs freshly initialized qubits.
        use qs = Qubit[nSites];

        // Each new qubit starts off in the |0〉 state, so we
        // apply the Hadamard gate, represented by the
        // Microsoft.Quantum.Intrinsic.H operation, in order to
        // prepare an initial state |+〉 for each qubit.
        // That is, we align all of the initial states with the
        // X operator.
        ApplyToEach(H, qs);

        // Next, we find the number of steps that we need to perform
        // the requested decomposition.
        let nSteps = Floor(time / dt);

        // We now define the terms in the Hamiltonian above
        // and provide specific values for each.
        // Transverse field:
        let hx = 1.0;

        // Longitudinal field:
        let hz = 0.5;

        // Ising coupling:
        let J = 1.0;

        // Having defined everything that we need, we can now proceed
        // to perform the actual Trotter–Suzuki decomposition and evolve
        // according to the Ising model Hamiltonian.

        // We do so by iterating over the number of time steps, and
        // applying each Hamiltonian term within each step and at each
        // site.
        for idxIter in 1..nSteps {

            // Find where we are in the sweep from the transverse
            // field to the final Ising model.
            let sweepParameter = IntAsDouble(idxIter) / IntAsDouble(nSteps);

            // In order to improve the locality of qubit references,
            // we apply all terms locally before proceeding to the next
            // site.
            for idxSite in 0 .. nSites - 1 {

                // Evolve under the transverse field for φx ≔ (1 - s) hx dt.
                Rx(((-2.0 * (1.0 - sweepParameter)) * hx) * dt, qs[idxSite]);

                // Evolve under the longitudinal field for φz ≔ s hz dt.
                Rz(((-2.0 * sweepParameter) * hz) * dt, qs[idxSite]);

                // If we aren't the last qubit, evolve under the Ising
                // coupling for φJ ≔ s J dt.
                if idxSite < nSites - 2 {
                    ApplyZZ((sweepParameter * J) * dt, qs[idxSite], qs[idxSite + 1]);
                }

            }
        }

        // Having thus approximated the evolution under the Ising
        // model Hamiltonian, we now measure each qubit in the Z basis and
        // return the results.
        return ForEach(MResetZ, qs);

    }

}
