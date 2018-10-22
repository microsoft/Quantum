// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Samples.Ising {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

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
    /// This initializes the qubits in an easy-to-prepare eigenstate of the 
    /// initial Hamiltonian.
    ///
    /// # Input
    /// ## qubits
    /// Qubit register encoding the Ising model quantum state.
    operation Ising1DStatePrep(qubits : Qubit[]) : () {
        body{
            ApplyToEachCA(H, qubits);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    //////////////////////////////////////////////////////////////////////////
    // More manual time-dependent simulation given `GeneratorSystem` /////////
    //////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// This uses the Ising model `GeneratorSystem` constructed previously to
    /// represent the desired interpolated Hamiltonian H(s). This is 
    /// accomplished by choosing an appropriate function for its coefficients.
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
    /// ## schedule
    /// Schedule parameter of interpolated Hamiltonian.
    ///
    /// # Output
    /// A `GeneratorSystem` representing the interpolated Hamiltonian H(s) of
    /// the Ising model.
    function IsingEvolutionScheduleImpl(nSites: Int, hXInitial: Double, hXFinal: Double, jFinal: Double, schedule: Double) : GeneratorSystem {
        let hX = GenerateUniformHCoupling( hXFinal * schedule + hXInitial * ( 1.0 - schedule), _);
        let jZ = GenerateUniform1DJCoupling(nSites, schedule * jFinal, _);

        let (evolutionSet, generatorSystem) = Ising1DEvolutionGenerator(nSites, hX, jZ);
        return generatorSystem;
    }

    /// # Summary
    /// We package the `GeneratorSystem` of the interpolated Hamiltonian H(s)
    /// as an `EvolutionSchedule` type by partial application of the schedule
    /// parameter.
    ///
    /// # Output
    /// An `EvolutionSchedule` type representing the interpolated Hamiltonian
    /// H(s).
    function IsingEvolutionSchedule(nSites: Int, hXInitial: Double, hXFinal: Double, jZFinal: Double) : EvolutionSchedule {
        // A `GeneratorSystem` only has meaning through an `EvolutionSet`.
        let evolutionSet = PauliEvolutionSet();
        return EvolutionSchedule(evolutionSet, IsingEvolutionScheduleImpl(nSites, hXInitial, hXFinal, jZFinal, _));
    }

    /// # Summary
    /// This feeds the Ising model `EvolutionSchedule` into a choice of 
    /// a `TimeDependentSimulationAlgorithm' to implement time-dependent
    /// evolution by the interpolated Hamiltonian over its schedule.
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
    /// ## timeDependentSimulationAlgorithm
    /// Choice of time-dependent simulation algorithm
    /// ## qubits
    /// Qubit register encoding the Ising model quantum state.
    operation IsingAdiabaticEvolutionManualImpl(nSites: Int, hXInitial: Double, hXFinal: Double, jFinal: Double, adiabaticTime: Double, timeDependentSimulationAlgorithm: TimeDependentSimulationAlgorithm, qubits : Qubit[]) : () {
        body {
            let evolutionSchedule = IsingEvolutionSchedule(nSites, hXInitial, hXFinal, jFinal);
            timeDependentSimulationAlgorithm(adiabaticTime, evolutionSchedule, qubits);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// We make a choice of the Trotter–Suzuki decomposition as our
    /// `TimeDependentSimulationAlgorithm` for implementing time-dependent
    /// evolution. We also use partial application over the qubit register
    /// to return a unitary operation.
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
    ///
    /// # Output
    /// A unitary operator implementing time-dependent evolution by the
    /// Hamiltonian H(s) when s is varied uniformly between 0 and 1 over time
    /// `adiabaticTime`.
    function IsingAdiabaticEvolutionManual(nSites: Int, hXInitial: Double, hXFinal: Double, jFinal: Double, adiabaticTime: Double, trotterStepSize: Double, trotterOrder: Int) : (Qubit[] => () : Adjoint, Controlled) {
        
        let timeDependentSimulationAlgorithm = TimeDependentTrotterSimulationAlgorithm(trotterStepSize, trotterOrder);
        
        return IsingAdiabaticEvolutionManualImpl(nSites, hXInitial, hXFinal, jFinal, adiabaticTime, timeDependentSimulationAlgorithm, _);

    }

    /// # Summary
    /// We now allocate qubits to the simulation, implement adiabatic state
    /// preparation, and then return the results of spin measurement on each
    /// site.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hXInitial
    /// Value of the coefficient `h` at s=0.
    /// ## jFinal
    /// Value of the coefficient `j` at s=1.
    /// ## adiabaticTime
    /// Time over which the schedule parameter is varied from 0 to 1.
    /// ## trotterStepSize
    /// Time simulated by each step of simulation algorithm.
    /// ## trotterOrder
    /// Order of Trotter–Suzuki integrator.
    ///
    /// # Output
    /// A `Result[]` storing the outcome of Z basis measurements on each site
    /// of the Ising model. 
    operation Ising1DAdiabaticAndMeasureManual(nSites : Int, hXInitial: Double, jFinal:Double, adiabaticTime: Double, trotterStepSize: Double, trotterOrder: Int) : Result[]{
        body{
            let hXFinal = 0.0;
            mutable results = new Result[nSites];
            using (qubits = Qubit[nSites]) {
                // This creates the ground state of the initial Hamiltonian.
                Ising1DStatePrep(qubits);
                (IsingAdiabaticEvolutionManual(nSites, hXInitial, hXFinal, jFinal, adiabaticTime, trotterStepSize, trotterOrder))(qubits);
                set results = MultiM(qubits);
                ResetAll(qubits);
            }
            return results;
        }
    }

    //////////////////////////////////////////////////////////////////////////
    // Time-dependent simulation using more built-in functions ///////////////
    //////////////////////////////////////////////////////////////////////////

    // In the previous section, we started from a description of the Ising
    // model where coupling terms were manually modified to simulate a schedule 
    // of deformation from the initial to the target Hamiltonian.

    // However, in some cases, we are provided with a description of the 
    // both Hamiltonians separately, and would like to avoid the need to
    // manually implement this interpolation. A complete description of
    // a Hamiltonian is an `EvolutionGenerator` type that contains 
    // both a `GeneratorSystem` that describes terms, and an `EvolutionSet` 
    // that maps each term to time-evolution by that term. This will be our 
    // starting point.

    /// # Summary
    /// This specifies the initial and target Hamiltonians as separate 
    /// `EvolutionGenerator` types.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hXCoupling
    /// Function returning coefficients `hₖ` for each site.
    /// ## jCoupling
    /// Function returning coefficients `jₖ` for each two-site interaction.
    ///
    /// # Output
    /// A `EvolutionGenerator` representing time evolution by each term of the
    /// initial and target Hamiltonians respectively. 
    function StartEvoGen(nSites: Int, hXCoupling: (Int -> Double)) : EvolutionGenerator {
        let XGenSys = OneSiteGeneratorSystem(1, nSites, hXCoupling);
        return EvolutionGenerator(PauliEvolutionSet(), XGenSys);
    }
    function EndEvoGen(nSites: Int, jCoupling: (Int -> Double)) : EvolutionGenerator {
        let ZZGenSys = TwoSiteGeneratorSystem(3, nSites, jCoupling);
        return EvolutionGenerator(PauliEvolutionSet(), ZZGenSys);
    }


    /// # Summary
    /// We  apply the function `AdiabaticEvolution` to automatically obtain 
    /// a unitary that implements time-dependent evolution by interpolating 
    // between two Hamiltonians. This requires a choice of 
    /// `TimeDependentSimulationAlgorithm`, and the time of simulation.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## adiabaticTime
    /// Time over which the schedule parameter is varied.
    /// from 0 to 1.
    /// ## trotterStepSize
    /// Time simulated by each step of simulation algorithm.
    /// ## trotterOrder
    /// Order of Trotter–Suzuki integrator.
    /// ## hXCoupling
    /// Function returning coefficients `hₖ` for each site.
    /// ## jCoupling
    /// Function returning coefficients `jₖ` for each two-site interaction.
    ///
    /// # Output
    /// a Unitary operator implementing time-dependent evolution by the
    /// Hamiltonian H(s) when s is varied uniformly between 0 and 1 over Time
    /// `adiabaticTime`.
    function IsingAdiabaticEvolutionBuiltIn(nSites: Int, adiabaticTime: Double, trotterStepSize: Double, trotterOrder: Int, hXCoupling: (Int -> Double), jCoupling: (Int -> Double) ) : (Qubit[] => () : Adjoint, Controlled) {
        // This is the initial Hamiltonian
        let start = StartEvoGen(nSites, hXCoupling);

        // This is the final Hamiltonian
        let end = EndEvoGen(nSites, jCoupling);
        
        // We choose the time-dependent Trotter–Suzuki decomposition as
        // our simulation algorithm.
        let timeDependentSimulationAlgorithm = TimeDependentTrotterSimulationAlgorithm(trotterStepSize, trotterOrder);
        
        // The function InterpolatedEvolution uniformly interpolates between the start and the end Hamiltonians.
        return InterpolatedEvolution(adiabaticTime, start, end, timeDependentSimulationAlgorithm);
    }

    /// # Summary
    /// We now choose uniform coupling coefficients, allocate qubits to the 
    /// simulation, implement adiabatic state preparation, and then return 
    /// the results of spin measurement on each site.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hXInitial
    /// Value of the coefficient `h` at s=0.
    /// ## jFinal
    /// Value of the coefficient `j` at s=1.
    /// ## adiabaticTime
    /// Time over which the schedule parameter is varied.
    /// from 0 to 1.
    /// ## trotterStepSize
    /// Time simulated by each step of simulation algorithm.
    /// ## trotterOrder
    /// Order of Trotter–Suzuki integrator.
    ///
    /// # Output
    /// A `Result[]` storing the outcome of Z basis measurements on each site
    /// of the Ising model. 
    operation Ising1DAdiabaticAndMeasureBuiltIn(nSites : Int, hXInitial: Double, jFinal: Double, adiabaticTime: Double, trotterStepSize: Double, trotterOrder: Int) : Result[]{
        body{
            let hXCoupling = GenerateUniformHCoupling( hXInitial, _);
            // For antiferromagnetic coupling, choose jFinal to be negative.
            let jCoupling = GenerateUniform1DJCoupling(nSites, jFinal, _);
            mutable results = new Result[nSites];
            using (qubits = Qubit[nSites]) {
                Ising1DStatePrep(qubits);
                (IsingAdiabaticEvolutionBuiltIn(nSites, adiabaticTime, trotterStepSize, trotterOrder, hXCoupling, jCoupling))(qubits);
                set results = MultiM(qubits);
                ResetAll(qubits);
            }
            return results;
        }
    }




}
