// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Chemistry.Hamiltonian {
    open Microsoft.Quantum.Core;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Chemistry.JordanWigner.VQE;


    /// # Summary
    /// Wrapper for Q# library function that expands the compact representation of
    /// the Jordan-Wigner coefficients in order to obtain a one-to-one mapping between
    /// these and Pauli terms.
    ///
    /// # Input
    /// ## coeff
    /// An array of coefficients, as read from the Jordan-Wigner Hamiltonian data structure.
    /// ## termType
    /// The type of the Jordan-Wigner term.
    ///
    /// # Output
    /// Expanded arrays of coefficients, one per Pauli term.
    function ExpandedCoefficients_(coeff : Double[], termType : Int) : Double[] {
        return ExpandedCoefficients(coeff, termType);
    }
    
    /// # Summary
    /// Prepare a simple trial state for H2 that is close to
    /// the ground state.
    ///
    /// # Input
    /// ## register
    /// The register in which to prepare the state.
    operation PrepareState (register: Qubit[]) : Unit is Adj {
        // Prepare a state that is close to the ground state of H2
        X(register[0]);
        X(register[1]);
    }

    /// # Summary
    /// Measure qubit register that is prepared in a state close to the ground
    /// state for a given measurement operator that corresponds to a single term
    /// in the Hamiltonian.
    /// This operation will be the entry point for an Azure Quantum service
    /// submission, and that the target will run it many times reporting the
    /// histogram over those shots
    ///
    /// # Input
    /// ## nOp
    /// The operator to apply.
    ///
    /// # Output
    /// The result measured on the qubit register.
    operation GetHamiltonianTermH2 (nOp : Int) : Result {
        // These measurement operators were generated using
        // the JordanWignerMeasurementOperators function but
        // hard-coded here for simplicity.
        //
        // To generate this list, use the 
        // JordanWignerMeasurementOperators function specified
        // in ChemUtils.qs.
        let measOps = [
            [PauliZ,PauliI,PauliI,PauliI],
            [PauliI,PauliZ,PauliI,PauliI],
            [PauliI,PauliI,PauliZ,PauliI],
            [PauliI,PauliI,PauliI,PauliZ],
            [PauliZ,PauliZ,PauliI,PauliI],
            [PauliZ,PauliI,PauliZ,PauliI],
            [PauliZ,PauliI,PauliI,PauliZ],
            [PauliI,PauliZ,PauliZ,PauliI],
            [PauliI,PauliZ,PauliI,PauliZ],
            [PauliI,PauliI,PauliZ,PauliZ],
            [PauliX,PauliX,PauliX,PauliX],
            [PauliY,PauliY,PauliY,PauliY],
            [PauliX,PauliX,PauliY,PauliY],
            [PauliY,PauliY,PauliX,PauliX],
            [PauliX,PauliY,PauliX,PauliY],
            [PauliY,PauliX,PauliY,PauliX],
            [PauliY,PauliX,PauliX,PauliY],
            [PauliX,PauliY,PauliY,PauliX]
        ];

        let nQubits = 4;
        use register = Qubit[nQubits];
        let op = measOps[nOp];
        PrepareState(register);
        let result = Measure(op, register);
        ResetAll(register);
        return result;
    }
}
