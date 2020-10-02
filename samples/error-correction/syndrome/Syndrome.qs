// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.ErrorCorrection.Syndrome {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
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
    operation MeasureInBasis(basis : Pauli, qubit : Qubit) : Result {
        return Measure([basis], [qubit]);
    }

    /// # Summary
    /// Prepare qubit in a given basis. Optionally flip the qubit if the value 
    /// is True (One).
    ///
    /// # Input
    /// ## basis
    /// Basis to prepare the qubit in
    /// ## qubit
    /// Qubit to prepare
    /// ## value
    /// Value to prepare the qubit in (True for One, False for Zero)
    operation PrepareInBasis(basis : Pauli, qubit : Qubit, value : Bool) : Unit {
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
    /// ## inputValues
    /// Array of Boolean input values for data qubits.
    /// ## encodingBases
    /// Array of Pauli bases to encode errors in for controlled Pauli operations on.
    /// The length of this array needs to be the same as 
    /// inputValues.
    /// ## qubitIndices
    /// List of qubit indices on which to apply controlled Pauli operators. 
    /// This determines the order in which the controlled Pauli's are applied.
    /// The length of this array needs to be the same as inputValues.
    /// 
    /// # Output
    /// ## (auxiliaryResult, dataResult)
    /// Tuple of the measurement results of the auxiliary qubit and data qubits.
    operation SamplePseudoSyndrome (
        inputValues : Bool[],
        encodingBases : Pauli[], 
        qubitIndices : Int[]
    ) : (Result, Result[]) {
        // Check that input lists are of equal length
        if ((Length(inputValues) != Length(encodingBases)) 
            or (Length(inputValues) != Length(qubitIndices))) {
            fail $"Lengths of input values, encoding bases and qubitIndices must be 
            equal. Found lengths: 
            {Length(inputValues)}, {Length(encodingBases)}, {Length(qubitIndices)}";
        }

        using ((block, auxiliary) = (Qubit[Length(inputValues)], Qubit())) {
            for ((qubit, value, basis) in Zipped3(block, inputValues, encodingBases)) {
                PrepareInBasis(basis, qubit, value);
            }

            H(auxiliary);
            // Apply Controlled Pauli operations to data qubits, resulting in a phase kickback 
            /// on the auxiliary qubit
            for ((index, basis) in Zipped(qubitIndices, encodingBases)) {
                Controlled ApplyPauli([auxiliary], ([basis], [block[index]]));
            }
            let auxiliaryResult = Measure([PauliX], [auxiliary]);
            let dataResult = ForEach(MeasureInBasis, Zipped(encodingBases, block));

            return (auxiliaryResult, dataResult);
        }
    }
}
