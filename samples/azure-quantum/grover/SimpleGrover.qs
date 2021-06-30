// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;

    /// # Summary
    /// This operation applies Grover's algorithm to search all possible inputs
    /// to an operation to find a particular marked state.
    ///
    /// # Input
    /// ## nQubits
    /// The number of qubits to allocate.
    /// ## idxMarked
    /// The index of the marked item to be found.
    ///
    /// # Output
    /// The computational basis state found in the final measurement.
    ///
    /// # Remarks
    /// If the operation worked correctly, the output should be a little-endian
    /// representation of `idxMarked`.
    @EntryPoint()
    operation SearchForMarkedInput(nQubits : Int, idxMarked : Int) : Result[] {
        use qubits = Qubit[nQubits];
        // Initialize a uniform superposition over all possible inputs.
        PrepareUniform(qubits);
        // The search itself consists of repeatedly reflecting about the
        // marked state and our start state, which we can write out in Q#
        // as a for loop.
        for _ in 0..NIterations(nQubits) - 1 {
            ReflectAboutMarked(idxMarked, qubits);
            ReflectAboutUniform(qubits);
        }
        // Measure and return the answer.
        return ForEach(MResetZ, qubits);
    }

    /// # Summary
    /// Returns the number of Grover iterations needed to find a single marked
    /// item, given the number of qubits in a register.
    ///
    /// # Input
    /// ## nQubits
    /// The number of qubits in the register to be searched over.
    ///
    /// # Output
    /// The optimal number of Grover's iterations to use for a register of
    /// size `nQubits`.
    function NIterations(nQubits : Int) : Int {
        let nItems = 1 <<< nQubits; // 2^numQubits
        // compute number of iterations:
        let angle = ArcSin(1. / Sqrt(IntAsDouble(nItems)));
        let nIterations = Round(0.25 * PI() / angle - 0.5);
        return nIterations;
    }

    /// # Summary
    /// Reflects about the basis state marked by a given index.
    /// This operation defines what input we are trying to find in the main
    /// search.
    ///
    /// # Input
    /// ## idxMarked
    /// The index of the marked item to be reflected about.
    /// ## inputQubits
    /// The register whose state is to be reflected about the marked input.
    operation ReflectAboutMarked(idxMarked : Int, inputQubits : Qubit[]) : Unit {
        use outputQubit = Qubit();
        within {
            // We initialize the outputQubit to (|0⟩ - |1⟩) / √2,
            // so that toggling it results in a (-1) phase.
            X(outputQubit);
            H(outputQubit);
        } apply {
            // Flip the outputQubit for marked states.
            // Here, we get the state given by the index idxMarked.
            (ControlledOnInt(idxMarked, X))(inputQubits, outputQubit);
        }
    }

}
