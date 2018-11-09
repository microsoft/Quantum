// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Type for register of physical qubits `Qubit[]` that encode the 
    /// logical qubits.
    newtype LogicalRegister = Qubit[];

    /// # Summary
    /// Type for measurement results `Result[]` that specify an error syndrome
    /// of a quantum code.
    newtype Syndrome = Result[];

    /// # Summary
    /// Type for function that maps an error syndrome to a sequence of `Pauli[]`
    /// operations that correct the detected error.
    newtype RecoveryFn = (Syndrome -> Pauli[]);

    // Design notes:
    //     These two types do not return (), such that instances of these types
    //     will not support autofunctors. This is inconvenient, but I think it's
    //     important to allow the generalization that physical and logical registers
    //     may have different numbers of qubits.

    /// # Summary
    /// Represents an operation which encodes a physical register into a
    /// logical register, using the provided scratch qubits.
    ///
    /// The first argument is taken to be the physical register that will
    /// be encoded, while the second argument is taken to be the scratch
    /// register that will be used.
    newtype EncodeOp = ((Qubit[], Qubit[]) => LogicalRegister);

    /// # Summary
    /// Represents an operation which decodes an encoded register into a
    /// physical register and the scratch qubits used to record a syndrome.
    ///
    /// The argument to a DecodeOp is the same as the return from an
    /// EncodeOp, and vice versa.
    newtype DecodeOp = (LogicalRegister => (Qubit[], Qubit[]));

    /// # Summary
    /// Represents an operation that is used to measure the syndrome
    /// of an error-correcting code block.
    ///
    /// # Example
    /// Measure syndromes for the bit-flip code
    /// $S = \langle ZZI, IZZ \rangle$ using scratch qubits in a
    /// non–fault tolerant manner:
    /// ```qsharp
    ///     let syndMeasOp = SyndromeMeasOp(MeasureStabilizerGenerators([
    ///             [PauliZ; PauliZ; PauliI];
    ///             [PauliI; PauliZ; PauliZ]
    ///         ], _, MeasureWithScratch));
    /// ```
    ///
    /// # Remarks
    /// The signature `(LogicalRegister => Syndrome)` represents an operation 
    /// that acts jointly on the qubits in `LogicalRegister` and some ancilla
    /// qubits followed by a measurements of the ancilla to extract a `Syndrome
    /// type representing the `Result[]` of these measurements.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.LogicalRegister
    /// - Microsoft.Quantum.Canon.Syndrome
    newtype SyndromeMeasOp = (LogicalRegister => Syndrome);

    /// # Summary
    /// Represents an error-correcting code as defined by its encoder,
    /// decoder, and syndrome measurement procedure.
    newtype QECC = (EncodeOp, DecodeOp, SyndromeMeasOp);

    /// # Summary
    /// Represents a Calderbank–Shor–Steane (CSS) code as defined by
    /// its encoder, decoder, and its syndrome measurement procedures
    /// for $X$ and $Z$ errors, respectively.
    newtype CSS = (EncodeOp, DecodeOp, SyndromeMeasOp, SyndromeMeasOp);

}
