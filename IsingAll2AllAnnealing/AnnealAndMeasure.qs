// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.IsingAll2All {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Extensions.Convert;


    // In this sample, the generator representation of the Ising model 
    // that we constructed in the Ising Generators Sample will be used as the
    // input to simulation algorithms in the canon. We will use these
    // simulation algorithms to realize adiabatic state preparation.

    // In adiabatic state preparation, we interpolate between two Hamiltonians.
    // We begin with the initial Hamiltonian Hᵢ, which has an easy-to-prepare 
    // ground state |ψᵢ〉. This Hamiltonian is then continuously deformed into
    // the target Hamiltonian Hₜ, with the desired ground state |ψₜ〉 that is 
    // typically more difficult to prepare. 

    // These define the interpolated Hamiltonian 
    //
    // H(s) = (1-s) Hᵢ + s Hₜ,
    //
    // where s ∈ [0,1] is a schedule parameter. Typically, the schedule
    // parameter is linearly related to the physical time t ∈ [0,T]. For 
    // instance, if interpolation between the Hamiltonians occur over a 
    // total time T, one may define
    //
    // s = t / T 
    //
    // This is of course not the only possible choice, and may be generalized
    // to s = f(t), where f is some arbitrary function that satisfies f(0) = 0
    // and f(T) = 1. Crucially, one necessary condition of the procedure is 
    // that H(s) is continuous with respect to s, and thus f(t) is a 
    // continuous function. 

    // By performing time-evolution by H(s) while slowly varying the schedule
    // from 0 to 1 over physical time T, the initial ground state |ψᵢ〉 remains 
    // an instantaneous ground state of H(s), and when s = 1, is then 
    // transformed into the target ground state |ψₜ〉. The probability of 
    // success improves the larger T is, equivalently, the more
    // slowly s is varied per unit of physical time. 
    
    // In many cases, the optimal physical time of the interpolation T is  
    // determined empirically. Though the worst-case rate of varying s can be
    // obtained from the gap of the Hamiltonian, which is the difference in 
    // energy between the instantaneous ground state and the first excited
    // state, computing the gap is in general an intractable problem.

    // In other situations, one may also choose a non-linear schedule f(t)
    // which may impart desirable properties, such as reduced error in state
    // preparation, or even allow for shorter T. Choosing the optimal f is,
    // however, a very difficult problem. For simplicity, we stick to the 
    // linear schedule.

    // For the Ising model, we choose the initial Hamiltonian to be just the
    // uniform transverse field coupling, and the target Hamiltonian to be
    // just the uniform two-site ZZ coupling.
    //
    // Hᵢ = - h ∑ₖ Xₖ,  
    // Hₜ = - j ∑ₖ ZₖZₖ₊₁
    //
    // Thus the ground state of Hᵢ is simply the |+〉 product state. The ground 
    // state of Hₜ in this case is actually also easy to prepare, but suffices
    // to demonstrate the procedure of adiabatic state preparation.

    // We provide two equivalent solutions to this problem.
    //
    // The first solution manually varies the coefficients on the Ising model
    // GeneratorSystem constructed previously to replicate the interpolated
    // Hamiltonian, which is then packaged as an `EvolutionSchedule` type. 
    // This is then fed into the time-dependent simulation algorithm which is 
    // of type `TimeDependentSimulationAlgorithm`, and acts on input qubits.
    //
    // The second solution could be more convenient in certain cases. We 
    // construct the start Hamiltonian Hᵢ and the target Hamiltonian Hₜ as
    // separate `EvolutionGenerator` types. Together with a choice of 
    // `TimeDependentSimulationAlgorithm`, these are then arguments of the 
    // library function `AdiabaticEvolution' which automatically interpolates
    // between these Hamiltonians and constructs the `EvolutionSchedule` type 
    // and implements time-dependent simulation on the input qubits.


    /// # Summary
    /// We now choose uniform coupling coefficients, allocate qubits to the 
    /// simulation, implement adiabatic state prepartion, and then return 
    /// the results of spin measurement on each site.
    ///
    /// # Input
    /// ## nQubits
    /// Number of qubits that the represented system will act upon.
    /// ## adiabaticTime
    /// Time over which the schedule parameter is varied.
    /// from 0 to 1.
    /// ## stepSize
    /// Time simulated by each step of simulation algorithm.
    ///
    /// # Output
    /// A `Result[]` storing the outcome of Z basis measurements on each site
    /// of the Ising model. 
    operation AnnealAndMeasure(
        nQubits: Int, 
        adiabaticTime: Double, 
        stepSize: Double, 
        initialize: (Qubit[] => () : Adjoint, Controlled), 
        driver: EvolutionGenerator, 
        problem: EvolutionGenerator) 
        : Result[] {
        body{
            mutable results = new Result[nQubits];

            // Compute number of Trotter steps
            let nSteps = Ceiling(adiabaticTime / stepSize);

            // Allocate qubits
            using (qubits = Qubit[nQubits]) {
                // Initialize qubits.
                initialize(qubits);

                // Make a loop where we ramp down the driver and ramp up the problem;
                for(idxStep in 0..nSteps - 1){
                    let schedule = ToDouble(idxStep) / ToDouble(nSteps);
                    // Apply driver Hamiltonian
                    ApplyHamiltonianEvolution(driver, stepSize * (1.0 - schedule), qubits);
                    // Apply problem Hamiltonian
                    ApplyHamiltonianEvolution(problem, stepSize * schedule, qubits);
                }

                // Measure qubits and return measurements;
                set results = MultiM(qubits);

                // Reinitialize qubits;
                ResetAll(qubits);
            }
            return results;
        }
    }

    operation ApplyHamiltonianEvolution(hamiltonian: EvolutionGenerator, stepSize: Double, qubits: Qubit[]) : () {
        body{
            let trotterOrder = 1;
            let simulationAlgorithm = TrotterSimulationAlgorithm(stepSize, trotterOrder);

            simulationAlgorithm(stepSize, hamiltonian, qubits);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// Alternate implementation using Canon time-dependent simulation algorithm routine
    operation AnnealAndMeasureAlternate(
        nQubits: Int, 
        adiabaticTime: Double, 
        stepSize: Double, 
        initialize: (Qubit[] => () : Adjoint, Controlled), 
        driver: EvolutionGenerator, 
        problem: EvolutionGenerator) 
        : Result[] {
        body{
            mutable results = new Result[nQubits];

            // Allocate qubits
            using (qubits = Qubit[nQubits]) {
                // Initialize qubits.
                initialize(qubits);

                // Make a loop where we ramp down the driver and ramp up the problem;
                (Annealing(nQubits, adiabaticTime, stepSize, driver, problem))(qubits);

                // Measure qubits and return measurements;
                set results = MultiM(qubits);

                // Reinitialize qubits;
                ResetAll(qubits);
            }
            return results;
        }
    }

    function Annealing(
        nQubits: Int,
        adiabaticTime: Double, 
        stepSize: Double, 
        driver: EvolutionGenerator, 
        problem: EvolutionGenerator) 
        : (Qubit[] => () : Adjoint, Controlled) {

        let trotterOrder = 1;
        let trotterStepSize = stepSize;

        // We choose the time-dependent Trotter–Suzuki decomposition as
        // our similation algorithm.
        let timeDependentSimulationAlgorithm = TimeDependentTrotterSimulationAlgorithm(trotterStepSize, trotterOrder);
        
        // The function InterpolatedEvolution uniformly interpolates between the start and the end Hamiltonians.
        return InterpolatedEvolution(adiabaticTime, driver, problem, timeDependentSimulationAlgorithm);
    }
}
