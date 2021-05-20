// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Chemistry.JordanWigner.Utils {
    open Microsoft.Quantum.Intrinsic;


    /// # Summary
    /// Expands the compact representation of the Jordan-Wigner coefficients in order
    /// to obtain a one-to-one mapping between these and Pauli terms.
    ///
    /// # Input
    /// ## coeff
    /// An array of coefficients, as read from the Jordan-Wigner Hamiltonian data structure.
    /// ## termType
    /// The type of the Jordan-Wigner term.
    ///
    /// # Output
    /// Expanded arrays of coefficients, one per Pauli term.
    function ExpandedCoefficients(coeff : Double[], termType : Int) : Double[]{
    
        // Compute the numbers of coefficients to return
        mutable nCoeffs = 0;
        if (termType == 2) {set nCoeffs = 2;}
        elif (termType == 3) {set nCoeffs = 8;}
        else {set nCoeffs = 1;}

        mutable coeffs = new Double[nCoeffs];

        // Return the expanded array of coefficients
        if ((termType == 0) or (termType == 1)) {
            set coeffs w/= 0 <- coeff[0];
        }
        elif ((termType == 2) or (termType == 3)) {
            for i in 0..nCoeffs-1 {
                set coeffs w/= i <- coeff[i/2];
            }
        }
        return coeffs;
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
    function JordanWignerMeasurementOperators(
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
        elif (termType == 3) {
            let compactOps = [[PauliX, PauliX, PauliX, PauliX], [PauliY, PauliY, PauliY, PauliY],
                              [PauliX, PauliX, PauliY, PauliY], [PauliY, PauliY, PauliX, PauliX],
                              [PauliX, PauliY, PauliX, PauliY], [PauliY, PauliX, PauliY, PauliX],
                              [PauliY, PauliX, PauliX, PauliY], [PauliX, PauliY, PauliY, PauliX]];
			      
            for iOp in 0..7 {
                mutable compactOp = compactOps[iOp];

                mutable op = new Pauli[nQubits];
                for i in 0..Length(indices)-1 {
                    let idx = indices[i];
                    let pauli = compactOp[i];
                    set op w/= idx <- pauli;
                }
                for i in indices[0]+1..indices[1]-1 {
                    set op w/= i <- PauliZ;
                }
                for i in indices[2]+1..indices[3]-1 {
                    set op w/= i <- PauliZ;
                }
		        set ops w/= iOp <- op; 
            }
	    }

        // Case of PQ and PQQR terms
        elif (termType == 2) {
            let compactOps = [[PauliX, PauliX], [PauliY, PauliY]];

            for iOp in 0..1 {
                mutable compactOp = compactOps[iOp];

                mutable op = new Pauli[nQubits];

                let nIndices = Length(indices);
                set op w/= indices[0] <- compactOp[0];
                set op w/= indices[nIndices-1] <- compactOp[1];
                for i in indices[0]+1..indices[nIndices-1]-1 {
                    set op w/= i <- PauliZ;
                }

                // Case of PQQR term
                if (nIndices == 4) {
                     set op w/= indices[1] <- ((indices[0] < indices[1]) and (indices[1] < indices[3])) ? PauliI | PauliZ;
                }
                set ops w/= iOp <- op;
            }
        }

        return ops;
    }
}
