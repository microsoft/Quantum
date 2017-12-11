// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.Ising {
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // In this sample, we demonstrate use of the generator representation
    // functionality offered by the Q# canon to represent Ising model
    // Hamiltonians.

    // Later, we will extend these techniques to represent the
    // 1D Heisenberg XXZ model.
    
    // We will begin by constructing a representation of the 1D transverse
    // Ising model Hamiltonian,
    //     H = - ( J₀ Z₀ Z₁ + J₁ Z₁ Z₂ + … ) - (h₀ X₀ + h₁ X₁ + …),
    // where {Jᵢ} are nearest-neighbor couplings, and where hₓ is a
    // transverse field.

    // Since this Hamiltonian is naturally expressed in the Pauli basis,
    // we will use the PauliEvolutionSet() function to obtain a simulatable
    // basis to use in representing H. Thus, we begin by defining our
    // indices with respect to the Pauli basis. In doing so, we will define
    // helper functions to return single-site and two-site generator indices.

    //////////////////////////////////////////////////////////////////////////
    // 1D Ising model ////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

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
    function OneSiteGeneratorIndex(idxPauli: Int, idxQubit: Int, hCoupling: (Int -> Double)) : GeneratorIndex {
        let coeff = - 1.0 * hCoupling(idxQubit);
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
    function OneSiteGeneratorSystem(idxPauli: Int, nSites: Int, hCoupling: (Int -> Double)) : GeneratorSystem {
        return GeneratorSystem(nSites, OneSiteGeneratorIndex(idxPauli, _, hCoupling));
    }
   
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
    function TwoSiteGeneratorIndex(idxPauli: Int, nSites: Int, idxQubit : Int , jCoupling: (Int -> Double)) : GeneratorIndex
    {
        /// when idxQubit is in [0, nSites - 1], apply Ising couplings jC(idxQubit)
        let idx = idxQubit;
        let coeff = - 1.0 * jCoupling(idx);
        let idxPauliString = [idxPauli; idxPauli];
        let idxQubits = [idx; (idx + 1) % nSites];
        let generatorIndex = GeneratorIndex((idxPauliString,[coeff]),idxQubits);
        if (idx >= nSites) {
            fail "Qubit index must be smaller than number of sites.";
        }
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
    function TwoSiteGeneratorSystem(idxPauli: Int, nSites: Int, jCoupling: (Int -> Double)) : GeneratorSystem
    {
        return GeneratorSystem(nSites,  TwoSiteGeneratorIndex(idxPauli, nSites, _, jCoupling));
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
    function IsingGeneratorSystem(nSites: Int, hXCoupling: (Int -> Double), jCoupling: (Int -> Double)) : GeneratorSystem {
        let XGenSys = OneSiteGeneratorSystem(1, nSites, hXCoupling);
        let ZZGenSys = TwoSiteGeneratorSystem(3, nSites, jCoupling);
        return AddGeneratorSystems(XGenSys, ZZGenSys);
    }

    // The generator system alone does not describe how its component terms
    // may be implemented on a quantum computer. In an EvolutionGenerator, 
    // a GeneratorSystem is described together with an EvolutionSet that maps 
    // each GeneratorIndex to unitary time-evolution by the term described.

    /// # Summary
    /// Returns an EvolutionGenerator for the Ising model.
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
    /// A `EvolutionGenerator` representing the sum - Σₖ Jₖ ZₖZₖ₊₁ - Σₖ hₖ Xₖ
    /// and a PauliEvolutionSet() that describes how unitary time-evolution by
    /// each term may be implemented.
    function Ising1DEvolutionGenerator(nSites : Int, hXCoupling: (Int -> Double),  jCoupling: (Int -> Double)) : EvolutionGenerator {
        let generatorSystem = IsingGeneratorSystem(nSites, hXCoupling, jCoupling);
        let evolutionSet = PauliEvolutionSet();
        return EvolutionGenerator(evolutionSet, generatorSystem);
    }

    // We now define functions for the coefficients

    /// # Summary
    /// A function that outputs uniform single-site coupling coefficients
    /// `hₖ`.
    ///
    /// # Input
    /// ## amplitude
    /// Value of coefficient.
    /// ## idxQubit
    /// Index `k` of the qubit that the represented term will act upon.
    ///
    /// # Output
    /// A function returning coefficients `hₖ` for each site.
    function GenerateUniformHCoupling( amplitude : Double, idxQubit : Int) : Double
    {
        return 1.0 * amplitude;
    }

    /// # Summary
    /// A function that outputs uniform two-site coupling coefficients
    /// `Jₖ` with open boundary conditions.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## amplitude
    /// Value of coefficient
    /// ## idxQubit
    /// Index `k` of the qubit that the represented term will act upon.
    ///
    /// # Output
    /// A function returning coefficients `Jₖ` for each site.
    function GenerateUniform1DJCoupling(nSites: Int, amplitude: Double, idxQubit: Int): Double {
        mutable coeff = amplitude;
        if(idxQubit == nSites - 1){
            set coeff = ToDouble(0);
        }
        return coeff;
    }

    // Let us construct a function to be called from C# that returns terms
    // of the Ising Hamiltonian. This unpacks the `EvolutionGenerator` created
    // by `Ising1DEvolutionGenerator`.

    /// # Summary
    /// Returns a generator index for a term in the Ising model with uniform
    /// couplings.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hXAmplitude
    /// Value of all `hₖ` coefficients.
    /// ## jAmplitude
    /// Value of all `jₖ` coefficients.
    /// ## idxHamiltonian
    /// Index to term in the Hamiltonian.
    ///
    /// # Output
    /// A `GeneratorIndex` representing a term in the Ising model. 
    function Ising1DUnpackEvolutionGenerator(nSites: Int, hXAmplitude : Double, jAmplitude: Double, idxHamiltonian: Int) : GeneratorIndex 
    {
        let hXCoupling = GenerateUniformHCoupling( hXAmplitude , _);
        let jCoupling = GenerateUniform1DJCoupling( nSites, jAmplitude, _);
        let (evolutionSet, generatorSystem) = Ising1DEvolutionGenerator(nSites, hXCoupling, jCoupling);
        let (nTerms, generatorIndexFunction) = generatorSystem;
        return generatorIndexFunction(idxHamiltonian);
    }

    //////////////////////////////////////////////////////////////////////////
    // 1D Heisenberg XXZ model ///////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // It is straightforward to generalize this to the Heisenberg XXZ model.

    /// # Summary
    /// Returns a generator system for the Heisenberg XXZ model.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hZCoupling
    /// Function returning coefficients `hₖ` for each site.
    /// ## jCoupling
    /// Function returning coefficients `Jₖ` for each two-site interaction.
    ///
    /// # Output
    /// A `GeneratorSystem` representing the sum 
    /// - Σₖ Jₖ ( XₖXₖ₊₁ + YₖYₖ₊₁ + ½ ZₖZₖ₊₁) - Σₖ hₖ Zₖ
    function HeisenbergXXZGeneratorSystem(nSites: Int, hZCoupling: (Int -> Double), jCoupling: (Int -> Double)) : GeneratorSystem {
        let ZGenSys = OneSiteGeneratorSystem(3, nSites, hZCoupling);
        let XXGenSys = TwoSiteGeneratorSystem(1, nSites, jCoupling);
        let YYGenSys = TwoSiteGeneratorSystem(2, nSites, jCoupling);
        // This multiplies all coefficients in a generator system
        let jZZmultiplier = 0.5;
        let ZZGenSys = MultiplyGeneratorSystem( jZZmultiplier, TwoSiteGeneratorSystem(3, nSites, jCoupling) );
        // We now add the transverse and coupling Hamiltonians
        return AddGeneratorSystems(AddGeneratorSystems(ZGenSys, ZZGenSys),AddGeneratorSystems(YYGenSys, XXGenSys));
    }   

    // Let us construct a function to be called from C# that returns terms
    // of the Heisenberg Hamiltonian. This unpacks the `GeneratorSystem` created
    // by `HeisenbergXXZGeneratorSystem`.

    /// # Summary
    /// Returns a generator index for a term in the Heisenberg model with uniform
    /// couplings.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## hZAmplitude
    /// Value of all `hₖ` coefficients.
    /// ## jAmplitude
    /// Value of all `jₖ` coefficients.
    /// ## idxHamiltonian
    /// Index to term in the Hamiltonian.
    ///
    /// # Output
    /// A `GeneratorIndex` representing a term in the Heisenberg Model. 
    function HeisenbergXXZUnpackGeneratorSystem(nSites: Int, hZAmplitude : Double, jAmplitude: Double, idxHamiltonian: Int) : GeneratorIndex 
    {
        let hZCoupling = GenerateUniformHCoupling( hZAmplitude , _);
        let jCoupling = GenerateUniform1DJCoupling( nSites, jAmplitude, _);
        let (nTerms, generatorIndexFunction) = HeisenbergXXZGeneratorSystem(nSites, hZCoupling, jCoupling);
        return generatorIndexFunction(idxHamiltonian);
    }

}
