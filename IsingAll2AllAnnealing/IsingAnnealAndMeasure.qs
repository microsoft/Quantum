// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Samples.IsingAll2All {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    /// # Summary
    /// Returns a generator index that is supported on a single site.
    ///
    /// # Input
    /// ## idxQubit
    /// Index `k` of the qubit that the represented term will act upon.
    /// ## hGlobal
    /// Multipler on coefficients `hₖ = 1.0` for each site. 
    ///
    /// # Output
    /// A `GeneratorIndex` representing the term - hₖ Xₖ, where hₖ is the
    /// constant `hCGlobal` evaluated at the site index `k`, and where
    /// Xₖ is the X Pauli operator acting on site index `k`.
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
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hGlobal
    /// Multipler on coefficients `hₖ = 1.0` for each site. 

    ///
    /// # Output
    /// A `GeneratorSystem` representing the sum - Σₖ hₖ Xₖ.
    function OneSiteGeneratorSystem(nSites: Int, hGlobal: Double) : GeneratorSystem {
        return GeneratorSystem(nSites, OneSiteGeneratorIndex(_, hGlobal));
    }


    // A complete description of
    // a Hamiltonian is an `EvolutionGenerator` type that contains 
    // both a `GeneratorSystem` that describes terms, and an `EvolutionSet` 
    // that maps each term to time-evolution by that term. This will be our 
    // starting point.

    /// # Summary
    /// This specifies the driver Hamiltonian as an
    /// `EvolutionGenerator` types.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hGlobal
    /// Multipler on coefficients `hₖ = 1.0` for each site. 
    ///
    /// # Output
    /// A `EvolutionGenerator` representing time evolution by each term of the
    /// driver Hamiltonians. 
    function IsingDriverHamiltonian(nSites: Int, hGlobal: Double) : EvolutionGenerator {
        let DriverGenSys =  OneSiteGeneratorSystem(nSites, hGlobal);
        return EvolutionGenerator(PauliEvolutionSet(), DriverGenSys);
    }

    // idxA, idxB, coefficient
    newtype jCoupling = (Int, Int, Double);

    /// # Summary
    /// Returns a generator index that is supported on two sites.
    ///
    /// # Input
    /// ## idxTerm
    /// Index `k` of the applied two-body term Jₖ Z_idxAₖ Z_idxBₖ.
    /// ## jGlobal
    /// Multipler on coefficients `Jₖ = 1.0` for each term. 
    /// ## jCouplingData
    /// Array of `jCoupling` terms in the format `(idxAₖ, idxBₖ, Jₖ)`.
    ///
    /// # Output
    /// A `GeneratorIndex` representing the term - Jₖ Z_idxAₖ Z_idxBₖ, 
    /// where Jₖ is the coefficient of the k-th term, and Z_idxAₖ, Z_idxBₖ are
    /// Z Pauli operators acting on the site idxAₖ and idxBₖ respectively.
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
    /// ## idxTerm
    /// Index `k` of the applied two-body term Jₖ Z_idxAₖ Z_idxBₖ.
    /// ## jGlobal
    /// Multipler on coefficients `Jₖ = 1.0` for each term. 
    /// ## jCouplingData
    /// Array of `jCoupling` terms in the format `(idxAₖ, idxBₖ, Jₖ)`.
    ///
    /// # Output
    /// A `GeneratorSystem` representing the sum - Σₖ Jₖ  Jₖ Z_idxAₖ Z_idxBₖ.
    function TwoSiteGeneratorSystem(jGlobal: Double, jCouplingData: jCoupling[]) : GeneratorSystem
    {
        let nTerms = Length(jCouplingData);
        return GeneratorSystem(nTerms, TwoSiteGeneratorIndex(_, jGlobal, jCouplingData));
    }
    
    /// # Summary
    /// This specifies the problem Hamiltonian as an
    /// `EvolutionGenerator` type.
    ///
    /// # Input
    /// ## idxTerm
    /// Index `k` of the applied two-body term Jₖ Z_idxAₖ Z_idxBₖ.
    /// ## jGlobal
    /// Multipler on coefficients `Jₖ = 1.0` for each term. 
    /// ## jCouplingData
    /// Array of `jCoupling` terms in the format `(idxAₖ, idxBₖ, Jₖ)`.
    ///
    /// # Output
    /// A `EvolutionGenerator` representing time evolution by each term of the
    /// problem Hamiltonians. 
    function IsingProblemHamiltonian(nSites: Int, jGlobal: Double, jCouplingData: jCoupling[]) : EvolutionGenerator {
        let ProblemGenSys =  TwoSiteGeneratorSystem(jGlobal, jCouplingData);
        return EvolutionGenerator(PauliEvolutionSet(), ProblemGenSys);
    }

    operation IsingAll2AllAnnealAndMeasure(nSites : Int, hGlobal: Double, jGlobal: Double, jCouplingData: jCoupling[], adiabaticTime: Double, stepSize: Double) : Result[] {
        body{
            // Number of qubits is equal to number of sites.
            let nQubits = nSites;

            // Initialize qubits by applying H gate to each.
            let initialize = ApplyToEachCA(H, _);

            // Ising Hamiltonians
            let driver = IsingDriverHamiltonian(nSites, hGlobal);
            let problem = IsingProblemHamiltonian(nSites, jGlobal, jCouplingData);

            // Apply annealing schedule and measure qubits.
            let results = AnnealAndMeasure(nQubits, adiabaticTime, stepSize, initialize, driver, problem);
        
            return results;
        }
    }

    /// Alternate implementation using Canon time-dependent simulation algorithm routine
    operation IsingAll2AllAnnealAndMeasureAlternate(nSites : Int, hGlobal: Double, jGlobal: Double, jCouplingData: jCoupling[], adiabaticTime: Double, stepSize: Double) : Result[] {
        body{
            // Number of qubits is equal to number of sites.
            let nQubits = nSites;

            // Initialize qubits by applying H gate to each.
            let initialize = ApplyToEachCA(H, _);

            // Ising Hamiltonians
            let driver = IsingDriverHamiltonian(nSites, hGlobal);
            let problem = IsingProblemHamiltonian(nSites, jGlobal, jCouplingData);

            // Apply annealing schedule and measure qubits.
            let results = AnnealAndMeasureAlternate(nQubits, adiabaticTime, stepSize, initialize, driver, problem);
        
            return results;
        }
    }

}
