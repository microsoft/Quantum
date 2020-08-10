// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.Hardware.Syndrome
{
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Core;

    /// # Summary
    /// Apply a controlled Pauli operation for a given basis and control/target qubits
    ///
    /// # Input
    /// ## basis
    /// Pauli basis in which to apply the controlled pauli
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
    /// This algorithm relies on several controlled pauli operations. When there is
    /// no error introduced after state preparation, the circuit is trivial and no 
    /// change is measured on the auxiliary qubit. However, if there are miscellaneous
    /// rotations on the data qubits due to noise, due to phase kickback the auxiliary
    /// qubit will gain a small phase shift. By measuring the auxiliary qubit in the
    /// X basis we then project that phase difference onto the measurement basis.
    ///
    /// # Input
    /// ## input_values
    /// List of boolean values for data qubits
    /// ## encoding_bases
    /// List of Pauli bases
    /// ## indexes
    /// List of indexes on which to apply controlled pauli operators
    operation SamplePseudoSyndrome (
            input_values: Bool[],
            encoding_bases: Pauli[], 
            indexes: Int[]
    ): ( Result, Result[] ) {
        using ((block, auxiliary) = (Qubit[Length(input_values)], Qubit())) {
            for ((qubit, value, basis) in Zip3(block, input_values, encoding_bases)) {
                Prepare(qubit, value, basis);
            }
            H(auxiliary);
            for (index in indexes) {
                ControlledPauli(encoding_bases[index], auxiliary, block[index]);
            }
            let auxiliary_result = Measure([PauliX], [auxiliary]);
            let data_result = ForEach(BasisMeasure, Zip(encoding_bases, block));
            Reset(auxiliary);
            return ( auxiliary_result, data_result );
        }
    }
}