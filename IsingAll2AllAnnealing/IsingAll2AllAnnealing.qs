// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Samples.Ising {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;


    /// # Summary
    /// Returns a generator index that is supported on a single site.
    ///
    /// # Input
    /// ## idxPauli
    /// Index of the Pauli operator to be represented, where `1` denotes 
    /// `PauliY` and `3` denotes `PauliZ`.
    /// ## idxQubit
    /// Index `k` of the qubit that the represented term will act upon.
    /// ## hCoupling
    /// Function returning coefficients `hₖ` for each site. E.g.: 
    /// should return the coefficient for the index at `idxQubit = 3`.
    ///
    /// # Output
    /// A `GeneratorIndex` representing the term - hₖ {Xₖ, Yₖ, Zₖ}, where hₖ is the
    /// function `hCoupling` evaluated at the site index `k`, and where
    /// {Xₖ, Yₖ, Zₖ}, selected by idxPauli, is the Pauli operator acting at the 
    /// site index `k`.
    function OneSiteGeneratorIndex(idxQubit: Int, hGlobal: Double) : GeneratorIndex {
        let idxPauli = 1;
        let coeff = - 1.0 * hGlobal;
        let idxPauliString = [idxPauli];
        let idxQubits = [idxQubit];
        return GeneratorIndex((idxPauliString, [coeff]), idxQubits);
    }

    /// # Summary
    /// Returns a generator system for a sum of generator indices each 
    /// supported on a single site.
    ///
    /// # Input
    /// ## idxPauli
    /// Index of the Pauli operator to be represented.
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hCoupling
    /// Function returning coefficients `hₖ` for each site.
    ///
    /// # Output
    /// A `GeneratorSystem` representing the sum - Σₖ hₖ {Xₖ, Yₖ, Zₖ}.
    function OneSiteGeneratorSystem(nSites: Int, hGlobal: Double) : GeneratorSystem {
        return GeneratorSystem(nSites, OneSiteGeneratorIndex(_, hGlobal));
    }

    // idxA, idxB, coefficient
    newtype jCoupling = (Int, Int, Double);

    /// # Summary
    /// Returns a generator index that is supported on two sites.
    ///
    /// # Input
    /// ## idxPauli
    /// Index of the Pauli operator to be represented, where `1` denotes 
    /// `PauliY` and `3` denotes `PauliZ`.
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## idxQubit
    /// Index `k` of the qubit that one of the represented term will act upon.
    /// ## jCoupling
    /// Function returning coefficients `Jₖ` for each two-site interaction. 
    /// E.g.: `jCoupling(3)` should return the coefficient for the index at 
    /// `idxQubit = 3`.
    ///
    /// # Output
    /// A `GeneratorIndex` representing the term - Jₖ {XₖXₖ₊₁, YₖYₖ₊₁, ZₖZₖ₊₁}, 
    /// where Jₖ is the function `jCoupling` evaluated at the site index `k`, 
    /// and where {XₖXₖ₊₁, YₖYₖ₊₁, ZₖZₖ₊₁}, selected by idxPauli, is the Pauli 
    /// operator acting at the site index `k` and `k+1` with closed boundary
    /// conditions.
    function TwoSiteGeneratorIndex(idxTerm : Int, jGlobal: Double, jCouplingData: jCoupling[]) : GeneratorIndex
    {
        let idxPauli = 3;
        let (idxA, idxB, coefficient) = jCouplingData[idxTerm];
        let coeff = - 1.0 * jGlobal * coefficient;
        let idxPauliString = [idxPauli; idxPauli];
        let idxQubits = [idxA; idxB];
        let generatorIndex = GeneratorIndex((idxPauliString, [coeff]), idxQubits);

        return generatorIndex;
    }

    /// # Summary
    /// Returns a generator system for a sum of generator indices each 
    /// supported on two neighboring sites.
    ///
    /// # Input
    /// ## idxPauli
    /// Index of the Pauli operator to be represented.
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## idxQubit
    /// Index `k` of the qubit that the represented term will act upon.
    /// ## jCoupling
    /// Function returning coefficients `Jₖ` for each two-site interaction.
    ///
    /// # Output
    /// A `GeneratorSystem` representing the sum - Σₖ Jₖ{XₖXₖ₊₁, YₖYₖ₊₁, ZₖZₖ₊₁}.
    function TwoSiteGeneratorSystem(jGlobal: Double, jCouplingData: jCoupling[]) : GeneratorSystem
    {
        let nTerms = Length(jCouplingData);
        return GeneratorSystem(nTerms, TwoSiteGeneratorIndex(_, jGlobal, jCouplingData));
    }
    
    // We now add the transverse and coupling Hamiltonians

    /// # Summary
    /// Returns a generator system for the Ising model.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hXCoupling
    /// Function returning coefficients `hₖ` for each site.
    /// ## jCoupling
    /// Function returning coefficients `Jₖ` for each two-site interaction.
    ///
    /// # Output
    /// A `GeneratorSystem` representing the sum - Σₖ Jₖ ZₖZₖ₊₁ - Σₖ hₖ Xₖ
    function IsingGeneratorSystem(nSites: Int, hGlobal: Double, jGlobal: Double, jCouplingData: jCoupling[]) : GeneratorSystem {
        let XGenSys = OneSiteGeneratorSystem(nSites, hGlobal);
        let ZZGenSys = TwoSiteGeneratorSystem(jGlobal, jCouplingData);
        return AddGeneratorSystems(XGenSys, ZZGenSys);
    }

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
    function StartEvoGen(nSites: Int, hStart: Double, jCouplingData: jCoupling[]) : EvolutionGenerator {
        let jStartGlobal = 0.0;
        let StartGenSys =  IsingGeneratorSystem(nSites, hStart, jStartGlobal, jCouplingData);
        return EvolutionGenerator(PauliEvolutionSet(), StartGenSys);
    }
    function EndEvoGen(nSites: Int, jEnd: Double, jCouplingData: jCoupling[]) : EvolutionGenerator {
        let hEndGlobal = 0.0;
        let EndGenSys =  IsingGeneratorSystem(nSites, hEndGlobal, jEnd, jCouplingData);
        return EvolutionGenerator(PauliEvolutionSet(), EndGenSys);
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
    function IsingAll2AllAdiabaticEvolution(nSites: Int, adiabaticTime: Double, trotterStepSize: Double, trotterOrder: Int, hStart: Double, jEnd: Double, jCouplingData: jCoupling[]) : (Qubit[] => () : Adjoint, Controlled) {
        // This is the initial Hamiltonian
        let start = StartEvoGen(nSites, hStart, jCouplingData);

        // This is the final Hamiltonian
        let end = EndEvoGen(nSites, jEnd, jCouplingData);
        
        // We choose the time-dependent Trotter–Suzuki decomposition as
        // our similation algorithm.
        let timeDependentSimulationAlgorithm = TimeDependentTrotterSimulationAlgorithm(trotterStepSize, trotterOrder);
        
        // The function InterpolatedEvolution uniformly interpolates between the start and the end Hamiltonians.
        return InterpolatedEvolution(adiabaticTime, start, end, timeDependentSimulationAlgorithm);
    }

    /// # Summary
    /// We now choose uniform coupling coefficients, allocate qubits to the 
    /// simulation, implement adiabatic state prepartion, and then return 
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
    operation IsingAll2AllAdiabaticAndMeasure(nSites : Int, hStart: Double, jEnd: Double, jCouplingData: jCoupling[], adiabaticTime: Double, trotterStepSize: Double, trotterOrder: Int) : Result[]{
        body{
            mutable results = new Result[nSites];

            // Allocate qubits
            using (qubits = Qubit[nSites]) {
                // Apply H to each
                Ising1DStatePrep(qubits);

                // Make a loop where we ramp down the driver and ramp up the problem;
                (IsingAll2AllAdiabaticEvolution(nSites, adiabaticTime, trotterStepSize, trotterOrder, hStart, jEnd, jCouplingData))(qubits);

                // Measure qubits and return measurements;
                set results = MultiM(qubits);

                // Reinitialize qubits;
                ResetAll(qubits);
            }
            return results;
        }
    }




}
