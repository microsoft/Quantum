// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Hubbard {

    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // In this example, we will show how to simulate the time evolution of
    // a 1D Hubbard model with `n` sites. Let `i` be the site index,
    // `s` = 1,0 be the spin index, where 0 is up and 1 is down. t be the
    // hopping coefficient, U the repulsion coefficient, and aᵢₛ the fermionic
    // annihilation operator on the fermion indexed by {i,s}. The Hamiltonian
    // of this model is

    //     H ≔ - t Σᵢ (a†ᵢₛ aᵢ₊₁ₛ + a†ᵢ₊₁ₛ aᵢₛ) + u Σᵢ a†ᵢ₁ aᵢ₁ a†ᵢ₀ aᵢ₀

    // Note that we use closed boundary conditions.

    // We do so in terms of the primitive gates defined by Q#. This requires
    // us to choose an encoding of Fermionic operators into qubits, and we
    // apply the Jordan-Wigner transformation for this task. We then use the
    // Trotter–Suzuki control sequence to approximate time-evolution by this
    // Hamiltonian. This time-evolution is used to estimate the ground state
    // energy at half-filling.

    // Energy estimation requires an input state with non-zero overlap with
    // the ground state, and we use the anti-ferromagnetic state with
    // alternating spins for this purpose.

    // The Hubbard Hamiltonian is composed of Fermionic operators which act on
    // Fermions and satisfy anti-commutation rules
    //
    // {aⱼ, aₖ} = 0, {a†ⱼ, aₖ†} = 0, {aⱼ, aₖ†} = δⱼₖ.

    // In the above, the subscript indexes both the site and spin.

    // If we assume that our underlying quantum machine is built upon
    // primitive operations acting on qubits, these Fermions and their
    // operators must be encoded as qubit operations. The mechanism to do so
    // is to map each Fermionic operator to a sequence of qubit operations
    // that satisfy the required anti-commutation rules.

    // One option for this mapping is known as the Jordan-Wigner
    // transformation, which maps each fermion index to a single qubit, and
    // maps the Fermionic operators as follows:

    // aⱼ → ½(Xⱼ + i Yⱼ) Zⱼ₋₁ Zⱼ₋₂ ... Z₀,   a†ⱼ → ½(Xⱼ - i Yⱼ) Zⱼ₋₁ Zⱼ₋₂ ... Z₀.

    // For instance, one may easily verify that the Hermitian operator
    // a†ⱼ aₖ + a†ₖ aⱼ maps to ½ ( Xⱼ Zⱼ₋₁ ... Zₖ₊₁ Xₖ + Yⱼ Zⱼ₋₁ ... Zₖ₊₁ Yₖ ),
    // assuming that j > k.

    // Other possible mappings exist, but we do not consider them further here.
    // Implementing the Jordan-Wigner transform requires us to define a
    // canonical ordering between the Fermion indices {is} and
    // the qubit index. Let the fermion site with index {is} correspond to the
    // qubit at the index i + n*s. For example, the fermionic mode a_{3↓} of a
    // chain with length 4 will correspond to the qubit at index 3 + 4 * 1 = 7.

    function FermionicIndexAsQubitIndex(nSites : Int, (idxSite : Int, idxSpin : Int)) : Int {
        return idxSite + nSites * idxSpin;
    }

    /// # Summary
    /// Returns an array of Pauli operators corresponding to a Jordan–Wigner
    /// string PZ...ZP
    ///
    /// # Input
    /// ## nQubits
    /// Number of qubits that the represented system will act upon.
    /// ## idxPauli
    /// Pauli operator P to be inserted at the ends of the Jordan–Wigner
    /// string
    /// ## idxQubitMin
    /// Smallest index to qubits in the Jordan–Wigner string
    /// ## idxQubitMax
    /// Largest index to qubits in the Jordan–Wigner string
    ///
    /// # Output
    /// An array of Pauli operators PZ...ZP of length nQubits padded by
    /// identity terms.
    ///
    /// # Example
    /// The following are equivalent:
    /// ```Q#
    /// let paulis = JordanWignerPZPString(5, PauliX, 3, 1);
    /// let paulis = [PauliI, PauliX, PauliZ, PauliX, PauliI];
    /// ```
    function JordanWignerPZPString(nQubits : Int, idxPauli : Pauli, idxQubitA : Int, idxQubitB : Int) : Pauli[] {
        let idxQubitMin = MinI(idxQubitA, idxQubitB);
        let idxQubitMax = MaxI(idxQubitA, idxQubitB);

        mutable pauliString = ConstantArray(nQubits, PauliI);

        for idxQubit in idxQubitMin + 1 .. idxQubitMax - 1 {
            set pauliString w/= idxQubit <- PauliZ;
        }

        return pauliString
            w/ idxQubitMin <- idxPauli
            w/ idxQubitMax <- idxPauli;
    }

    // We may now simulate time-evolution by the Fermionic hopping terms,
    // which are each now expressed as Jordan-Wigner strings.

    /// # Summary
    /// Implements time-evolution by a single hopping term.
    ///
    /// # Input
    /// ## nSites
    /// Number of sites in the Hubbard Hamiltonian.
    /// ## idxSite
    /// Index to a site in the Hubbard Hamiltonian.
    /// ## idxSpin
    /// Index to the spin of a site in the Hubbard Hamiltonian.
    /// ## coefficient
    /// Coefficient of the hopping term in the Hubbard Hamiltonian.
    /// ## qubits
    /// Qubits that the encoded Hubbard Hamiltonian acts on.
    operation ApplyHubbardHoppingTerm(nSites : Int, idxSite : Int, idxSpin : Int, coefficient : Double, qubits : Qubit[]) : Unit is Adj + Ctl {
        // The number of qubits in this encoding is as follows
        let nQubits = 2 * nSites;

        if (not (idxSpin == 0 or idxSpin == 1)) {
            fail "Fermion spin index must be 0 or 1.";
        }

        // This is how we index the qubits
        let idxQubitA = FermionicIndexAsQubitIndex(nSites, (idxSite, idxSpin));
        let idxQubitB = FermionicIndexAsQubitIndex(nSites, ((idxSite + 1) % nSites, idxSpin));
        let JordanWignerStringX = JordanWignerPZPString(nQubits, PauliX, idxQubitA, idxQubitB);
        let JordanWignerStringY = JordanWignerPZPString(nQubits, PauliY, idxQubitA, idxQubitB);
        Exp(JordanWignerStringX, 0.5 * coefficient, qubits);
        Exp(JordanWignerStringY, 0.5 * coefficient, qubits);
    }


    // We may now simulate time-evolution by the Fermionic repulsion terms.

    /// # Summary
    /// Implements time-evolution by a single repulsion term.
    ///
    /// # Input
    /// ## nSites
    /// Number of sites in the Hubbard Hamiltonian.
    /// ## idxSite
    /// Index to a site in the Hubbard Hamiltonian.
    /// ## coefficient
    /// Coefficient of the hopping term in the Hubbard Hamiltonian.
    /// ## qubits
    /// Qubits that the encoded Hubbard Hamiltonian acts on.
    operation ApplyHubbardRepulsionTerm(nSites : Int, idxSite : Int, coefficient : Double, qubits : Qubit[]) : Unit is Adj + Ctl {
        let idxQubitA = FermionicIndexAsQubitIndex(nSites, (idxSite, 0));
        let idxQubitB = FermionicIndexAsQubitIndex(nSites, (idxSite, 1));
        let coefficientZ = coefficient * 0.25;
        Exp([PauliZ], -coefficientZ, [qubits[idxQubitA]]);
        Exp([PauliZ], -coefficientZ, [qubits[idxQubitB]]);
        Exp([PauliZ, PauliZ], coefficientZ, [qubits[idxQubitA], qubits[idxQubitB]]);
        // Instead of applying a global phase, we may simply track it
        // and add the result to the energy estimate later.
    }

    // Let us now combine these two contributions to the Hubbard Hamiltonian
    // in a single operation that maps an integer indexing a term in the
    // Hamiltonian to time-evolution by that term alone.

    /// # Summary
    /// Implements time-evolution by a single term in the Hubbard Hamiltonian.
    ///
    /// # Input
    /// ## nSites
    /// Number of sites in the Hubbard Hamiltonian.
    /// ## tCoefficient
    /// Coefficient of hopping term.
    /// ## uCoefficient
    /// Coefficient of repulsion term.
    /// ## idxHamiltonian
    /// Index to a term in the Hubbard Hamiltonian.
    /// ## stepSize
    /// Duration of single step of time-evolution
    /// ## qubits
    /// Qubits that the encoded Hubbard Hamiltonian acts on.
    operation _ApplyHubbardTerm(nSites : Int, tCoefficient : Double, uCoefficient : Double, idxHamiltonian : Int, stepSize : Double, qubits : Qubit[])
    : Unit is Adj + Ctl {
        // when idxHamiltonian is in [0, 2 * nSites - 1], we return a hopping term
        // when idxHamiltonian is in [2 * nSites, 3 * nSites - 1], we return a repulsion term
        if (idxHamiltonian < 2 * nSites) {
            let idxSite = (idxHamiltonian / 2) % nSites;
            let idxSpin = idxHamiltonian % 2;
            ApplyHubbardHoppingTerm(nSites, idxSite, idxSpin, tCoefficient * stepSize, qubits);
        } else {
            let idxSite = idxHamiltonian % nSites;
            ApplyHubbardRepulsionTerm(nSites, idxSite, uCoefficient * stepSize, qubits);
        }
    }


    // We will simulate time-evolution using the Trotter–Suzuki family of
    // integrators. For example, given a matrix A + B that is a sum of
    // non-commuting terms A and B, the first-order integrator approximates
    // e^{(A + B)t} by decomposing into the product of 2r exponentials

    // e^{(A + B)t} = (e^{A t/ r} e^{B t/ r})^r + O(t^2(|A| + |B|)^2 / r).

    // Note that this approximation holds for all matrices, not just the
    // anti-Hermitian matrices of interest in quantum simulation.

    // The Trotter decomposition is a general procedure for integration
    // and we implement it as a function that acts on general types. Its
    // specialization to approximating Hamiltonian time-evolution requires
    // in input with signature

    // (Int, ((Int, Double, Qubit[]) => () is Adj + Ctl)

    // The first parameter records the number of terms in the sum.
    // The second parameter performs a unitary operation, classically
    // controlled by an integer index to the desired unitary, and a
    // real parameter for the step size t / r.

    // We now invoke the Trotter–Suzuki control structure. This requires two
    // additional parameters — the trotterOrder, which determines the order
    // the Trotter decompositions, and the trotterStepSize, which determines
    // the duration of time-evolution of a single Trotter step.

    /// # Summary
    /// Returns a unitary operation that simulates time evolution by the
    /// Hamiltonian for a single Trotter step.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## tCoefficient
    /// Coefficient of hopping term.
    /// ## uCoefficient
    /// Coefficient of repulsion term.
    /// ## trotterOrder
    /// Order of Trotter integrator.
    /// ## trotterStepSize
    /// Duration of simulated time-evolution in single Trotter step.
    ///
    /// # Output
    /// A unitary operation.
    function HubbardTrotterEvolution(nSites : Int, tCoefficient : Double, uCoefficient : Double, trotterOrder : Int, trotterStepSize : Double)
    : (Qubit[] => Unit is Adj + Ctl) {
        let nTerms = nSites * 3;
        let op = (nTerms, _ApplyHubbardTerm(nSites, tCoefficient, uCoefficient, _, _, _));
        return DecomposedIntoTimeStepsCA(op, trotterOrder)(trotterStepSize, _);
    }

    // We now define an operation that prepares the anti-Ferromagnetic initial
    // and estimates the ground state energy using time evolution by the
    // Hubbard Hamiltonian.

    /// # Summary
    /// Implements time-evolution by the Hubbard Hamiltonian on a line of qubits
    /// initialized in an antiferromagnetic state, then performs phase estimation
    /// to estimate the energy of the antiferromagnetic configuration at half
    /// filling.
    ///
    /// # Input
    /// ## nSites
    /// Number of qubits that the represented system will act upon.
    /// ## tCoefficient
    /// Coefficient of hopping term.
    /// ## uCoefficient
    /// Coefficient of repulsion term.
    /// ## nBitsPrecision
    /// The number of bits of precision to use in phase estimation.
    /// ## trotterStepSize
    /// Duration of simulated time-evolution in single Trotter step.
    ///
    /// # Output
    /// An estimate of the energy of the antiferromagnetic state at half filling.
    operation EstimateHubbardAntiFerromagneticEnergy(nSites : Int, tCoefficient : Double, uCoefficient : Double, nBitsPrecision : Int, trotterStepSize : Double) : Double {

        // Number of qubits in this encoding is equal to the number of
        // Fermion sites * number of spin indices.
        let nQubits = 2 * nSites;

        // Let us use the first-order Trotter–Suzuki decomposition.
        let trotterOrder = 1;

        // The input to phase estimation requires a DiscreteOracle type.
        let qpeOracle = OracleToDiscrete(HubbardTrotterEvolution(nSites, tCoefficient, uCoefficient, trotterOrder, trotterStepSize));

        use qubits = Qubit[nQubits];
        // This prepares the antiferromagnetic initial state
        // at half filling by adding one electron to each site with
        // alternating spins.
        for idxSite in 0 .. nSites - 1 {
            let idxSpin = idxSite % 2;
            let idxQubit = nSites * idxSpin + idxSite;
            X(qubits[idxQubit]);
        }

        // We now call the robust phase estimation procedure and
        // divide by the trotterStepSize to normalize the estimate
        // to units of energy.
        let energyEst =
            RobustPhaseEstimation(nBitsPrecision, qpeOracle, qubits) / trotterStepSize
            // We add the contribution of the global phase here.
            + (IntAsDouble(nSites) * uCoefficient) * 0.25;

        // We must reset all qubits to the |0〉 state before releasing them.
        ResetAll(qubits);

        // We return the energy estimate here.
        return energyEst;
    }

}
