// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.Ising {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;
        // Needed for Ceiling.
    open Microsoft.Quantum.Extensions.Convert;
        // Needed to ToDouble.

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    
    // In this example, we will show how to simulate the time evolution of
    // an Ising model under a transverse field,
    //
    //     H ≔ - J Σ'ᵢⱼ Zᵢ Zⱼ - hZ Σᵢ Zᵢ - hX Σᵢ Xᵢ
    //
    // where the primed summation Σ' is taken only over nearest-neighbors.
    // We also use open boundary conditions in this example.

    // We do so by directly using the higher-order Trotterization control 
    // structure. This control structure iterates over a list of time-
    // evolution operators, and selects the stepsize of time-evolution 
    // and their ordering by the Trotter–Suzuki decomposition. This allows us
    // to decouple the choice of simulation algorithm Trotterization from
    //  the representation of the Hamiltonian.

    // Using a sequence of short time-evolutions, we may simulate
    // time-evolution over a longer time interval. We use this to
    // investigate how an excitation caused by single spin-flip at one 
    // end of the Ising chain propagates down it.

    // When the transverse field hX is zero, the single-excitation state 
    // |100...0> is an eigenstate of the Hamiltonian H. Thus time-evolution by
    // H will not change the magnetization of other sites. However, with the 
    // transverse field on, |100...0> is no longer an eigenstate, which allows
    // the excitation to diffuse to neighbouring sites. One then expects the
    // average magnetization of the leftmost site to decrease in general, and
    // that of other sites to relax away from 0.

    // We begin by defining an operation that takes an index to a term
    // in the Hamiltonian, and applies time-evolution by that term alone for
    // some specified time.

    /// # Summary
    /// Implements time-evolution by a single term in the Ising Hamiltonian. 
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hXCoupling
    /// Value of hX.
    /// ## hZCoupling
    /// Value of hZ.
    /// ## jCoupling
    /// Value of J.
    /// ## idxHamiltonian
    /// An integer in [0, 3 * nSites - 2] that indexes one of the 
    /// 3 * nSites - 1 terms in the Hamiltonian.
    /// ## stepSize
    /// Duration of time-evolution by term in Hamiltonian.
    /// ## qubits
    /// Qubit register Hamiltonian acts on.
    operation Ising1DTrotterUnitariesImpl(nSites : Int, hXCoupling : Double, hZCoupling: Double, jCoupling: Double, idxHamiltonian: Int, stepSize : Double, qubits : Qubit[]) : ()
    {
        body {
            // when idxHamiltonian is in [0, nSites - 1], apply transverse field "hx"
            // when idxHamiltonian is in [nSites, 2 * nSites - 1], apply and longitudinal field "hz"
            // when idxHamiltonian is in [2 * nSites, 3 * nSites - 2], apply Ising coupling "jC"
            if(idxHamiltonian <= nSites - 1){
                Exp([PauliX], -1.0 * hXCoupling * stepSize, [qubits[idxHamiltonian]]);
            }
            elif(idxHamiltonian <= 2 * nSites - 1){
                Exp([PauliZ], -1.0 * hZCoupling * stepSize, [qubits[idxHamiltonian % nSites]]);
            }
            else{
                Exp([PauliZ; PauliZ],  -1.0 * jCoupling * stepSize, qubits[(idxHamiltonian % nSites)..((idxHamiltonian + 1) % nSites)]);
            }
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    // The input to the Trotterization control structure has a type
    // (Int, ((Int, Double, Qubit[]) => () : Adjoint, Controlled))
    // The first parameter Int is the number of terms in the Hamiltonian
    // The first parameter in ((Int, Double, Qubit[])) is an index to a term
    // in the Hamiltonian
    // The second parameter in ((Int, Double, Qubit[])) is the stepsize
    // The third parameter in  ((Int, Double, Qubit[])) are the qubits the
    // Hamiltonian acts on.
    // Let us create this type from Ising1DTrotterUnitariesImpl by partial
    // applications.

    /// # Summary
    /// Returns a description of the Ising Hamiltonian that is compatible with
    /// the Trotterization control structure.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hXCoupling
    /// Value of hX.
    /// ## hZCoupling
    /// Value of hZ.
    /// ## jCoupling
    /// Value of J.
    /// 
    /// # Output
    /// A tuple containing the number of terms in the Hamiltonian and a
    /// unitary operation classically controlled by the term index and 
    /// stepsize.
    function Ising1DTrotterUnitaries(nSites : Int, hXCoupling : Double, hZCoupling: Double, jCoupling: Double) : (Int, ((Int, Double, Qubit[]) => () : Adjoint, Controlled))
    {
        let nTerms = 3 * nSites - 1;
        return (nTerms, Ising1DTrotterUnitariesImpl(nSites, hXCoupling, hZCoupling, jCoupling, _, _, _));
    }

    // We now invoke the Trotterization control structure. This requires two 
    // additional parameters -- the trotterOrder, which determines the order 
    // the Trotter decompositions, and the trotterStepSize, which determines 
    // the duration of time-evolution of a single Trotter step.

    /// # Summary
    /// Returns a unitary operation that simulates time evolution by the
    /// Hamiltonian for a single Trotter step.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hXCoupling
    /// Value of hX.
    /// ## hZCoupling
    /// Value of hZ.
    /// ## jCoupling
    /// Value of J.
    /// ## trotterOrder
    /// Order of Trotter integrator.
    /// ## trotterStepSize
    /// Duration of simulated time-evolution in single Trotter step.
    /// 
    /// # Output
    /// A unitary operation.
    function Ising1DTrotterEvolution(nSites : Int, hXCoupling : Double, hZCoupling: Double, jCoupling: Double, trotterOrder: Int, trotterStepSize: Double) : (Qubit[] => (): Adjoint, Controlled)
    {
        let op = Ising1DTrotterUnitaries(nSites, hXCoupling, hZCoupling, jCoupling);
        return (DecomposeIntoTimeStepsCA(op,trotterOrder))(trotterStepSize, _);
    }

    // We now define an operation that initializes the qubits, prepares the
    // initial single-excitation, performs time-evolution by the Ising
    // Hamiltonian, and returns the results of measurement on each site.
    /// # Summary
    /// Implements time-evolution by the Ising Hamiltonian on a line of qubits
    /// initialized in |100...0> state, then measures each site.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## simulationTime
    /// Time interval of simulation
    /// ## trotterOrder
    /// Order of Trotter integrator.
    /// ## trotterStepSize
    /// Duration of simulated time-evolution in single Trotter step.
    ///
    /// # Output
    /// Array of single-site measurement results.
    operation Ising1DExcitationCorrelation(nSites : Int, simulationTime: Double, trotterOrder: Int, trotterStepSize: Double) : Result[] {
        body{

            // Let us allocate an array to hold the measurement results.
            mutable results = new Result[nSites];

            // Let us set the hZ coupling to zero as it will not be needed.
            let hZCoupling = ToDouble(0);
             
            // We pick arbitrary values for the X and J couplings
            let hXCoupling = ToDouble(1);
            let jCoupling = ToDouble(1);

            // This determines the number of Trotter steps
            let steps = Ceiling(simulationTime / trotterStepSize);

            // This resizes the Trotter step so that time evolution over the 
            // duration is accomplished.
            let trotterStepSizeResized = simulationTime / ToDouble(steps);

            // Let us initialize nSites clean qubits. These are all in the |0>
            // state.
            using(qubits = Qubit[nSites]){

                // We now create a spin flip excitation on the 0th site
                X(qubits[0]);

                // We then evolve for some time 
                for(idxStep in 0..steps - 1){
                    (Ising1DTrotterEvolution(nSites, hXCoupling, hZCoupling, jCoupling, trotterOrder, trotterStepSizeResized))(qubits);    
                }

                // We now measure each site and return the results 
                set results = MultiM(qubits);

                // The qubits must be returned to the |0> state.
                ResetAll(qubits);

            }
            return results;
        }
    }


}
