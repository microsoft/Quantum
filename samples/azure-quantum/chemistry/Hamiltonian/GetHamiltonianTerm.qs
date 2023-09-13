// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Chemistry.Hamiltonian {
    open Microsoft.Quantum.Core;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Chemistry.JordanWigner.VQE;
    open Microsoft.Quantum.Arrays;


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
    operation GetHamiltonianTerm (nOp : Int, mesOps : Pauli[]) : Result {
        // These measurement operators were generated using
        // the JordanWignerMeasurementOperators function but
        // hard-coded here for simplicity.
        //
        // To generate this list, use the 
        // JordanWignerMeasurementOperators function specified
        // in ChemUtils.qs.
        let PauliMap = [PauliI, PauliX, PauliZ, PauliY];

        let nQubits = 4;
        use register = Qubit[nQubits];
        let op = mesOps;
        PrepareState(register);
        let result = Measure(op, register);
        ResetAll(register);
        return result;
    }

    /// # Summary
    /// Computes all the measurement operators required to compute the expectation of a Jordan-Wigner term.
    ///
    /// # Input
    /// ## nQubits
    /// The number of qubits required to simulate the molecular system.
    /// ## indices
    /// An array containing the indices of the qubit each Pauli operator is applied to.
    /// ## termType
    /// The type of the Jordan-Wigner term.
    ///
    /// # Output
    /// An array of measurement operators (each being an array of Pauli).
    operation JordanWignerMeasurementOperators(
            nQubits : Int, 
            indices : Int[], 
            termType : Int
    ) : Pauli[][] {

        // Compute the size and initialize the array of operators to be returned
        mutable nOps = 0;
        if (termType == 2) {set nOps = 2;}
        elif (termType == 3) {set nOps = 8;}
        else {set nOps = 1;}

        mutable ops = new Pauli[][nOps];

        // Z and ZZ terms
        if ((termType == 0) or (termType == 1)) {
            mutable op = new Pauli[nQubits];
            for idx in indices {
                set op w/= idx <- PauliZ;
            }
            set ops w/= 0 <- op;
        }

        // PQRS terms set operators between indices P and Q (resp R and S) to PauliZ
        elif termType == 3 {
            let compactOps = [[PauliX, PauliX, PauliX, PauliX], [PauliY, PauliY, PauliY, PauliY],
                              [PauliX, PauliX, PauliY, PauliY], [PauliY, PauliY, PauliX, PauliX],
                              [PauliX, PauliY, PauliX, PauliY], [PauliY, PauliX, PauliY, PauliX],
                              [PauliY, PauliX, PauliX, PauliY], [PauliX, PauliY, PauliY, PauliX]];

            for (idxOp, compactOp) in Enumerated(compactOps) {

                mutable op = new Pauli[nQubits];
                for (idx, pauli) in Zipped(indices, compactOp) {
                    set op w/= idx <- pauli;
                }
                for i in indices[0]+1..indices[1]-1 {
                    set op w/= i <- PauliZ;
                }
                for i in indices[2]+1..indices[3]-1 {
                    set op w/= i <- PauliZ;
                }
                set ops w/= idxOp <- op; 
            }
	    }

        // Case of PQ and PQQR terms
        elif (termType == 2) {
            let compactOps = [[PauliX, PauliX], [PauliY, PauliY]];

            for (idxOp, compactOp) in Enumerated(compactOps) {

                mutable op = new Pauli[nQubits];

                let nIndices = Length(indices);
                set op = op w/ indices[0] <- compactOp[0]
                            w/ indices[nIndices-1] <- compactOp[1];
                for i in indices[0]+1..indices[nIndices-1]-1 {
                    set op w/= i <- PauliZ;
                }

                // Case of PQQR term
                if nIndices == 4 {
                     set op w/= indices[1] <- ((indices[0] < indices[1]) and (indices[1] < indices[3])) ? PauliI | PauliZ;
                }
                set ops w/= idxOp <- op;
            }
        }

        return ops;
    }
}
