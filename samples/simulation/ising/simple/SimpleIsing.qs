// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.SimpleIsing {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

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
    /// ## coupling
    /// Ising coupling parameters in the form of an array of arrays of length 
    /// 2, where the outer array index is the index of a site, and the inner 
    /// array is the index of the coupling site and the coupling parameter value. 
    ///
    /// # Output
    /// The results of Z measurements on each qubit.
    ///
    /// # Remarks
    /// This operation allocates qubits internally to use in simulation,
    /// such that it is straightforward to call this operation from
    /// conventional .NET code.
    operation SimulateIsingEvolution(
            nSites : Int, 
            time : Double, 
            dt : Double, 
            coupling : (Int, Double)[][]
        ) : Result[] {
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

        // Having defined everything that we need, we can now proceed
        // to perform the actual Trotter–Suzuki decomposition and evolve
        // according to the Ising model Hamiltonian.

        // We do so by iterating over the number of time steps, and
        // applying each Hamiltonian term within each step and at each
        // site.
        for idxIter in 0 .. nSteps - 1 {

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
                if (idxSite < nSites - 2) {
                    for (idxOther, J) in coupling[idxSite] {
                        ApplyZZ(
                            (sweepParameter * J) * dt,
                            qs[idxSite],
                            qs[idxOther]
                        );
                    }
                }
            }
        }

        // Having thus approximated the evolution under the Ising
        // model Hamiltonian, we now measure each qubit in the Z basis and
        // return the results.
        return ForEach(MResetZ, qs);
    }

    /// # Summary
    /// Helper function for computing the magnetization 
    /// by converting each Result into a floating point number.
    internal function AddMagnetization(current : Double, spinMeasurement : Result) : Double {
        return current + (spinMeasurement == One ? 0.5 | -0.5); 
    }

    /// # Summary
    /// Create an array of site-to-site couplings.
    /// This supports either a chain, cycle or all-to-all coupled Ising lattice.
    /// Here we use a constant Ising coupling J. Optionally the value can be 
    /// set to -J, depending on the parity of the lattice index.
    ///
    /// # Input
    /// ## nSites
    /// Number of sites in Ising lattice
    /// ## J
    /// Site-to-site coupling parameter
    /// ## signByParity
    /// Set sign of coupling parameter by the index parity
    /// ## cycle
    /// Couple the last lattice site in the chain to the first
    /// ## allToAll
    /// Couple all lattice sites to each other
    ///
    /// # Result
    /// ## couplings
    /// Array of arrays with coupling parameters
    function GenerateCouplings(
        nSites : Int,
        J : Double,
        signByParity: Bool,
        cycle: Bool,
        allToAll: Bool
    ) : (Int, Double)[][] {
        let numCouplings = cycle == true or allToAll == true ? nSites - 2 | nSites - 1;
        mutable couplings = new (Int, Double)[][nSites];
        mutable sign = 1.0;

        for i in 0 .. numCouplings {
            if (signByParity) {
                set sign = (i + 1) % nSites == 0 ? 1.0 | -1.0;
            }
            set couplings w/= i <- [( i+1, sign * J )];

            if (allToAll) {
                for j in i + 1 .. numCouplings {
                    set couplings w/= i <- couplings[i] + [( i+1, sign * J )];
                }
            }
        }
        // Assert that couplings has the expected shape
        if (allToAll) {
            EqualityFactI(Length(couplings[0]), numCouplings + 1, "Inner array has wrong length");
        } else {
            EqualityFactI(Length(couplings[0]), 1, "Inner array should have length 1");
        }
        
        return couplings;
    }
}
