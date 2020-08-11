// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.Hardware.Syndrome {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Core;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;

    /// # Summary
    /// Apply a controlled Pauli operation for a given basis and control/target qubits
    ///
    /// # Input
    /// ## basis
    /// Basis in which to apply the controlled Pauli operation.
    /// ## control
    /// Control qubit
    /// ## target
    /// Target qubit
    operation ControlledPauli(basis: Pauli, control: Qubit, target: Qubit): Unit {
        if (PauliZ == basis) {
            CZ(control, target);
        }
        if (PauliX == basis) {
            CX(control, target);
        }
        if (PauliY == basis) {
            CY(control, target);
        }
    }

    /// # Summary
    /// Measure qubit in a given basis and return the result
    ///
    /// # Input
    /// ## basis_qubit
    /// Tuple of the Pauli basis and qubit to measure
    /// 
    /// # Output
    /// ## result
    /// Measurement result
    operation BasisMeasure(basis_qubit: (Pauli, Qubit)): Result {
        let (basis, qubit) = basis_qubit;
        let result = Measure([basis], [qubit]);
        Reset(qubit);
        return result;
    }

    operation Prepare(qubit: Qubit, value: Bool, basis: Pauli): Unit {
        if (value) {
            X(qubit);
        }
        PrepareQubit(basis, qubit);
    }

    /// # Summary
    /// Creates a Pseudo Syndrome by using an auxiliary qubit.
    /// This algorithm relies on several controlled Pauli operations. When 
    /// there is no error introduced after state preparation, the circuit is 
    /// trivial and no change is measured on the auxiliary qubit. However, if 
    /// there are miscellaneous rotations on the data qubits due to noise, due
    /// to phase kickback the auxiliary qubit will gain a small phase shift. 
    /// By measuring the auxiliary qubit in the X basis we then project that 
    /// phase difference onto the measurement basis.
    ///
    /// # Input
    /// ## input_values
    /// List of boolean values for data qubits
    /// ## encoding_bases
    /// List of Pauli bases
    /// ## qubit_indices
    /// List of qubit indices on which to apply controlled pauli operators
    operation SamplePseudoSyndrome (
            input_values: Bool[],
            encoding_bases: Pauli[], 
            qubit_indices: Int[]
    ): ( Result, Result[] ) {
        // Check that input lists are of equal length
        if ((Length(input_values) != Length(encoding_bases)) 
            or (Length(input_values) != Length(qubit_indices))) {
            fail "Lengths of input values, encoding bases and qubit_indices must be 
            equal. Found lengths: " 
            + IntAsString(Length(input_values)) + ", " 
            + IntAsString(Length(encoding_bases)) + ", " 
            + IntAsString(Length(qubit_indices)) + ".";
        }

        using ((block, auxiliary) = (Qubit[Length(input_values)], Qubit())) {
            for ((qubit, value, basis) in Zip3(block, input_values, encoding_bases)) {
                Prepare(qubit, value, basis);
            }
            H(auxiliary);
            for (index in qubit_indices) {
                ControlledPauli(encoding_bases[index], auxiliary, block[index]);
            }
            let auxiliary_result = Measure([PauliX], [auxiliary]);
            let data_result = ForEach(BasisMeasure, Zip(encoding_bases, block));
            Reset(auxiliary);
            return ( auxiliary_result, data_result );
        }
    }
}
