// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.SimpleIsing {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math; // Needed for Floor.
    open Microsoft.Quantum.Extensions.Convert; // Needed to ToDouble.


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
    // In terms of the primitive gates defined by Q#, we can write
    // this by conjugating an Rz rotation by CNOTs. Later, we will see
    // how this can be written more compactly using operations and functions
    // from the canon, and how to use other primitive operations to
    // exponentiate arbitrary Pauli operators.
    
    /// # Summary
    /// Given two qubits and a rotation angle, rotates the given
    /// qubits about ZZ.
    ///
    /// # Input
    /// ## phi
    /// Angle by which to rotate the given qubits.
    operation ApplyZZ( phi : Double, q1 : Qubit, q2 : Qubit ) : () { 
        body {     
            CNOT(q1, q2);
            Rz(- 2.0 * phi, q2);
            CNOT(q1, q2);
        }
        
        // It's generally good practice to denote that an operation
        // can be automatically adjointed and controlled. We will do so
        // here, even though we do not directly use either functor in this
        // example.
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    // With this operation in place, we can now decompose evolution
    // under the full Hamiltonian H given above using the Trotter–Suzuki
    // decomposition. For simplicity, we'll use the first-oder Trotter–Suzuki
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
    operation Ising(nSites : Int, time : Double, dt : Double) : Result[] {
        body {

            // We start by allocating an array to hold measurement results,
            // so that we can return them when we are done.
            mutable result = new Result[nSites];

            // Next, we use the using keyword to declare that the following
            // block needs freshly initialized qubits.
            using (qs = Qubit[nSites]) {

                // Each new qubit starts off in the |0〉 state, so we
                // apply the Hadamard gate, represented by the
                // Microsoft.Quantum.Primitive.H operation, in order to
                // prepare an initial state |+〉 for each qubit.
                // That is, we align all of the initial states with the
                // X operator.
                for (idxQubit in 0..Length(qs) - 1) {
                    H(qs[idxQubit]);
                }

                // Next, we find the number of steps that we need to perform
                // the requested decomposition.
                let nSteps = Floor(time / dt);

                // We now define the terms in the Hamiltonian above
                // and provide specific values for each.
                // Transverse field:
                let hx = 1.0;
                // Longitiduinal field:
                let hz = 0.5;
                // Ising coupling:
                let J = 1.0;

                // Having defined everything that we need, we can now proceed
                // to perform the actual Trotter–Suzuki decomposition and evolve
                // according to the Ising model Hamiltonian.

                // We do so by iterating over the number of time steps, and
                // applying each Hamiltonian term within each step and at each
                // site.
                for (idxIter in 0..nSteps - 1) {
                    // Find where we are in the sweep from the transverse
                    // field to the final Ising model.
                    let sweepParameter = ToDouble(idxIter) / ToDouble(nSteps);

                    // In order to improve the locality of qubit references,
                    // we apply all terms locally before proceeding to the next
                    // site.
                    for (idxSite in 0..nSites - 1) {
                        // Evolve under the transverse field for φx ≔ (1 - s) hx dt.
                        Rx(- 2.0 * (1.0 - sweepParameter) * hx * dt, qs[idxSite]);
                        // Evolve under the longitiduinal field for φz ≔ s hz dt.
                        Rz(- 2.0 * sweepParameter * hz * dt, qs[idxSite]);
                        // If we aren't the last qubit, evolve under the Ising
                        // coupling for φJ ≔ s J dt.
                        if (idxSite < nSites - 2) {
                            ApplyZZ(sweepParameter * J * dt, qs[idxSite], qs[idxSite + 1]);
                        }
                    }

                }

                // Having thus approximated the evolution under the Ising
                // model Hamiltonian, we now measure each qubit in the Z basis and
                // return the results.
                for (idxQubit in 0..Length(qs) - 1) {
                    set result[idxQubit] = M(qs[idxQubit]);
                    // If we observed that we were in the |1〉 state, the
                    // -1 eigenstate of Z, then we need to flip it back to
                    // a |0〉 state before releasing.
                    if (result[idxQubit] == One){
                        X(qs[idxQubit]);
                    }
                }

            }

            // Once the `using` block above ends, all of the qubits that
            // we allocated are automatically made available again, such that
            // we can now finish up by returning the measurement results
            // that we collected.
            return result;
        }
    }

}

