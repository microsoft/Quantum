// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Samples.Ising {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // In this sample, we estimate the energy of the Ising model ground state.
    // This uses the technique of adiabatic state preparation constructed in
    // the `AdiabaticIsingSample` to prepare the ground state, and then 
    // applies a phase estimation algorithm. 
    
    // The iterative phase estimation algorithm discussed in 
    // `PhaseEstimationSample` is one of many possible variants. The 
    // algorithm there is based on an adaptive sequence of measurements that 
    // requires a unitary oracle that can be exponentiated by arbitrary
    // real numbers. In our case, we restrict the oracle to be just integer 
    // powers of a single Trotter time step. Thus one compatible choice here 
    // is the Robust phase estimation algorithm, which also happens to be non-
    /// adaptive, and provides a instructive contrasting implementation.

    // We provide two solutions. 
    // In the first solution, we manually construct and put together all the 
    // ingredients needed for this task. This provides the most flexiblity. 
    // In the second solution, we use a built-in function in the simulation 
    // library that is less flexible, but takes care of most of the 
    // implementation details.
   
    /// # Summary
    /// This defines the unitary on which phase estimation is performed.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hXFinal
    /// Value of the coefficient `h` at s=1.
    /// ## jFinal
    /// Value of the coefficient `j` at s=1.
    /// ## qpeStepSize
    /// Size of Trotter step in simulation algorithm.
    /// ## qubits
    /// Qubit register encoding the Ising model quantum state.
    operation IsingQPEUnitary(nSites: Int, hXFinal: Double, jFinal: Double, qpeStepSize: Double, qubits: Qubit[]) : () {
        body {
            // The Hamiltonian used for phase estimation here is the Ising
            // model defined previously at the schedule parameter s = 1.
            let hXInitial = hXFinal;
            let schedule = 1.0;
            // We use a Trotter–Suzuki `SimulationAlgorithm` to implement the 
            // Trotter step of size `qpeStepSize`.
            let trotterOrder = 1;
            let simulationAlgorithm = TrotterSimulationAlgorithm(qpeStepSize, trotterOrder);
            // The input to a `SimulationAlgorithm` is an `EvolutionGenerator`
            let evolutionSet = PauliEvolutionSet();
            let evolutionGenerator = EvolutionGenerator(evolutionSet , IsingEvolutionScheduleImpl(nSites, hXInitial, hXFinal, jFinal, schedule));
            // We simulate the Ising model for time ``qpeStepSize`, 
            // corresponding to one Trotter step.
            simulationAlgorithm(qpeStepSize, evolutionGenerator, qubits);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }


    //////////////////////////////////////////////////////////////////////////
    // Manual adiabatic state preparation and phase estimation ///////////////
    //////////////////////////////////////////////////////////////////////////

    // We now create an operation callable from C# that performs all steps 
    // of the algorithm. For maximum flexibility, this necessarily many input
    // parameters, though we emphasize that each part of the algorithm 
    // e.g. the choices of `adiabaticEvolution` or `qpeAlgorithm` are
    // conceptually separate.

    /// # Summary
    /// We perform adiabatic state preparation, and then phase estimation on
    /// the resulting state.
    /// 
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hXInitial
    /// Value of the coefficient `h` at s=0.
    /// ## hXFinal
    /// Value of the coefficient `h` at s=1.
    /// ## jFinal
    /// Value of the coefficient `j` at s=1.
    /// ## adiabaticTime
    /// Time over which the schedule parameter is varied from 0 to 1.
    /// ## trotterStepSize
    /// Time simulated by each step of simulation algorithm.
    /// ## trotterOrder
    /// Order of Trotter–Suzuki integrator.
    /// ## qpeStepSize
    /// Size of Trotter step in simulation algorithm.
    /// ## nBitsPrecision
    /// Bits of precision in phase estimation algorithm
    ///
    /// # Output
    /// An `Double` for the estimate of the Ising ground state energy, and a 
    /// `Result[]` containing single-site measurement outcomes.
    ///    
    /// # References 
    /// We use the Robust Phase Estimation algorithm of Kimmel et al.
    /// (https://arxiv.org/abs/1502.02677)
    operation IsingEstimateEnergy(nSites: Int, hXInitial: Double, hXFinal: Double, jFinal: Double, adiabaticTime: Double, trotterStepSize: Double, trotterOrder: Int, qpeStepSize: Double, nBitsPrecision: Int) : (Double, Result[]) {
        body{
            // Define the input to the phase estimation algorithm.
            let qpeOracle = OracleToDiscrete (IsingQPEUnitary(nSites, hXFinal, jFinal, qpeStepSize, _) );

            // Choose the robust phase estimation algorithm.
            let qpeAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);

            // Define the unitary that implements adiabatic state 
            // preparation.
            let adiabaticEvolution = IsingAdiabaticEvolutionManual(nSites, hXInitial, hXFinal, jFinal, adiabaticTime, trotterStepSize, trotterOrder);

            // Allocate variables that store the output.
            mutable phaseEst = 0.0;
            mutable results = new Result[nSites];

            // Allocate clean qubits for the computation.
            using(qubits = Qubit[nSites]){

                // Prepare the ground state of the initial Hamiltonian.
                Ising1DStatePrep(qubits);

                // Prepare the ground state of the target Hamiltonian.
                adiabaticEvolution(qubits);

                // Estimate the energy of the ground state.
                set phaseEst = qpeAlgorithm(qpeOracle, qubits) / qpeStepSize;

                // Measurement the spin of the ground state.
                set results = MultiM(qubits);

                // Reset qubits to the |0〉 state.
                ResetAll(qubits);
            }

            // Return the results.
            return (phaseEst, results);
        }
    }

 
    //////////////////////////////////////////////////////////////////////////
    // Built-in Adiabatic state preparation and phase estimation /////////////
    //////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// We perform adiabatic state preparation, and then phase estimation on
    /// the resulting state. We use built-in function 
    /// `AdiabaticStateEnergyEstimate` which automatically allocates qubits,
    /// performs state preparation, and then phase estimation.
    /// 
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hXInitial
    /// Value of the coefficient `h` at s=0.
    /// ## hXFinal
    /// Value of the coefficient `h` at s=1.
    /// ## jFinal
    /// Value of the coefficient `j` at s=1.
    /// ## adiabaticTime
    /// Time over which the schedule parameter is varied from 0 to 1.
    /// ## trotterStepSize
    /// Time simulated by each step of simulation algorithm.
    /// ## trotterOrder
    /// Order of Trotter–Suzuki integrator.
    /// ## qpeStepSize
    /// Size of Trotter step in simulation algorithm.
    /// ## nBitsPrecision
    /// Bits of precision in phase estimation algorithm
    ///
    /// # Output
    /// An `Double` for the estimate of the Ising ground state energy.
    operation IsingEstimateEnergy_Builtin(nSites: Int, hXInitial: Double, hXFinal: Double, jFinal: Double, adiabaticTime: Double, trotterStepSize: Double, trotterOrder: Int, qpeStepSize: Double, nBitsPrecision: Int) : Double {
        body{
            // Prepare ground state of initial Hamiltonian.
            let statePrepUnitary = Ising1DStatePrep;
            
            // Unitary for adiabatic evolution.
            let adiabaticUnitary = IsingAdiabaticEvolutionManual(nSites, hXInitial, hXFinal, jFinal, adiabaticTime, trotterStepSize, trotterOrder) ;
            
            // Oracle for phase estimation.
            let qpeUnitary = IsingQPEUnitary(nSites, hXFinal, jFinal, qpeStepSize, _);

            // Choice of phase esitmation algorithm.
            let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);

            // Execute the entire procedure to obtain an energy estimate.
            let phaseEst = AdiabaticStateEnergyEstimate(nSites, statePrepUnitary, adiabaticUnitary, qpeUnitary, phaseEstAlgorithm) / qpeStepSize;
            
            // Return the estimated energy.
            return phaseEst;
        }
    }

}
