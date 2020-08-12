// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.ErrorCorrection.Syndrome
{
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Core;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;

    /// # Summary
    /// Measure qubit in a given basis and return the result
    ///
    /// # Input
    /// ## basis
    /// Pauli basis in which to perform measurement
    /// ## qubit
    /// Qubit to measure
    /// 
    /// # Output
    /// ## result
    /// Measurement result
    operation BasisMeasure(basis: Pauli, qubit: Qubit): Result {
        let result = Measure([basis], [qubit]);
        return result;
    }

    /// # Summary
    /// Prepare qubit in a given basis. Optionally flip the qubit if the value is True (One).
    ///
    /// # Input
    /// ## qubit
    /// Qubit to prepare
    /// ## value
    /// Value to prepare the qubit in (True for One, False for Zero)
    /// ## basis
    /// Basis to prepare the qubit in
    operation PrepareInBasis(qubit: Qubit, value: Bool, basis: Pauli): Unit {
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
    /// Array of Boolean input values for data qubits.
    /// ## encoding_bases
    /// Array of Pauli bases to encode errors in for controlled Pauli operations on.
    /// The length of this array needs to be the same as 
    /// input_qubits.
    /// ## qubit_indices
    /// List of qubit indices on which to apply controlled Pauli operators. 
    /// This determines the order in which the controlled Pauli's are applied.
    /// The length of this array needs to be the same as input_qubits.
    /// 
    /// # Output
    /// ## (auxiliary_result, data_result)
    /// Tuple of the measurement results of the auxiliary qubit and data qubits.
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
                PrepareInBasis(qubit, value, basis);
            }
            H(auxiliary);
            // Apply Controlled Pauli's to data qubits, resulting in a phase kickback 
            /// on the auxiliary qubit
            for ((qubit, basis) in Zip(block, encoding_bases)) {
                Controlled ApplyPauli([auxiliary], ([basis], [qubit]));
            }
            let auxiliary_result = Measure([PauliX], [auxiliary]);
            let data_result = ForEach(BasisMeasure, Zip(encoding_bases, block));
            // Reset qubits - optional, only for QDK version < 0.12
            ResetAll(block);
            Reset(auxiliary);
            return ( auxiliary_result, data_result );
        }
    }
}
