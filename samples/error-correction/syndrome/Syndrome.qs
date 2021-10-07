// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.ErrorCorrection.Syndrome {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Random;

    /// # Summary
    /// Runs the Syndrome sample.
    ///
    /// # Input
    /// ## nQubits
    /// The number of qubits to use.
    @EntryPoint()
    operation RunSyndrome(nQubits : Int) : Unit {
        // Choose a random ordering of qubits for the syndrome by creating an array of qubit indices
        // [0, 1, ..., nQubits - 1] and shuffling it.
        let qubitIndices = Shuffle(RangeAsIntArray(0 .. nQubits - 1));

        // Choose a random initial value and Pauli basis for each qubit. To do this, use DrawMany to
        // repeatedly call random sampling operations for Boolean and Pauli values, and collect
        // their results into two arrays of length nQubits.
        let inputValues = DrawMany(DrawRandomBool, nQubits, 0.5);
        let encodingBases = DrawMany(Choose, nQubits, [PauliX, PauliY, PauliZ]);

        let (auxiliary, data) = SamplePseudoSyndrome(inputValues, encodingBases, qubitIndices);

        Message(
            $"Inputs: {inputValues}\n" +
            $"Bases: {encodingBases}\n" +
            $"Qubit indices: {qubitIndices}\n" +
            $"Auxiliary: {auxiliary}\n" +
            $"Data qubits: {data}"
        );
    }

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
    internal operation MeasureInBasis(basis : Pauli, qubit : Qubit) : Result {
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
    internal operation PrepareInBasis(basis : Pauli, qubit : Qubit, value : Bool) : Unit {
        if (value) {
            X(qubit);
        }
        PreparePauliEigenstate(basis, qubit);
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
    internal operation SamplePseudoSyndrome (
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

        use block = Qubit[Length(inputValues)];
        use auxiliary = Qubit();
        for (qubit, value, basis) in Zipped3(block, inputValues, encodingBases) {
            PrepareInBasis(basis, qubit, value);
        }

        H(auxiliary);
        // Apply Controlled Pauli operations to data qubits, resulting in a phase kickback 
        // on the auxiliary qubit
        for (index, basis) in Zipped(qubitIndices, encodingBases) {
            Controlled ApplyPauli([auxiliary], ([basis], [block[index]]));
        }
        let auxiliaryResult = Measure([PauliX], [auxiliary]);
        let dataResult = ForEach(MeasureInBasis, Zipped(encodingBases, block));

        return (auxiliaryResult, dataResult);
    }

    /// # Summary
    /// Shuffles the order of elements in an array.
    ///
    /// # Input
    /// ## xs
    /// The array.
    ///
    /// # Output
    /// The shuffled array.
    internal operation Shuffle<'T>(xs : 'T[]) : 'T[] {
        mutable ys = xs;
        for i in Length(xs) - 1 .. -1 .. 1 {
            let j = DrawRandomInt(0, i);
            set ys = ys w/ j <- ys[i] w/ i <- ys[j];
        }

        return ys;
    }

    /// # Summary
    /// Chooses a random element from a non-empty array. Fails if the array is empty.
    ///
    /// # Input
    /// ## xs
    /// The array.
    ///
    /// # Output
    /// A random element from the array.
    internal operation Choose<'T>(xs : 'T[]) : 'T {
        let (success, x) = MaybeChooseElement(xs, DiscreteUniformDistribution(0, Length(xs) - 1));
        Fact(success, "Array is empty.");
        return x;
    }
}
