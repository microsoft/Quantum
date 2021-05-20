namespace Microsoft.Quantum.Chemistry.Hamiltonian {
    open Microsoft.Quantum.Core;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    
    /// # Summary
    /// Prepare a simple trial state for H2 that is close to
    // the ground state.
    ///
    /// # Input
    /// ## register
    /// The register in which to prepare the state.
    operation PrepareState (register: Qubit[]) : Unit is Adj {
        body (...) {
            // Prepare a state that is close to the ground state of H2
            X(register[0]);
            X(register[1]);
        }

        // Define a non-matching adjoint body for compliance with EstimateFrequencyA
        adjoint (...) {
            ResetAll(register);
        }
    }

    /// # Summary
    /// Get the energy for a given measurement operator that corresponds
    /// to a single term in the Hamiltonian.
    ///
    /// # Input
    /// ## nOp
    /// The operator to apply.
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
