// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;

    /// # Summary
    /// Private operation used to implement both the bit flip encoder and decoder.
    ///
    /// Note that this encoder can make use of in-place coherent recovery,
    /// in which case it will "cause" the error described
    /// by the initial state of `auxQubits`.
    /// In particular, if `auxQubits` are initially in the state $\ket{10}$, this
    /// will cause an $X_1$ error on the encoded qubit.
    ///
    /// # References
    /// - doi:10.1103/PhysRevA.85.044302
    operation BFEncoderImpl(coherentRecovery : Bool, data : Qubit[], scratch : Qubit[])  : ()
    {
        body {
            if (coherentRecovery) {
                (Controlled(X))(scratch, data[0]);
            }
            (Controlled(X))(data, scratch[0]);
            (Controlled(X))(data, scratch[1]);
        }

        adjoint auto
    }

    /// # Summary
    /// Encodes into the [3, 1, 3] / ⟦3, 1, 1⟧ bit-flip code.
    ///
    /// # Input
    /// ## physRegister
    /// A register of physical qubits representing the data to be protected.
    /// ## auxQubits
    /// A register of auxillary qubits initially in the $\ket{00}$ state to be
    /// used in encoding the data to be protected.
    ///
    /// # Output
    /// The physical and auxillary qubits used in encoding, represented as a
    /// logical register.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.LogicalRegister
    operation BitFlipEncoder(physRegister : Qubit[], auxQubits : Qubit[])  : LogicalRegister
    {
        body {
            BFEncoderImpl(false, physRegister, auxQubits);

            let logicalRegister = LogicalRegister(physRegister + auxQubits);
            return logicalRegister;
        }
    }

    /// # Summary
    /// Decodes from the [3, 1, 3] / ⟦3, 1, 1⟧ bit-flip code.
    ///
    /// # Input
    /// ## logicalRegister
    /// A code block of the bit-flip code.
    ///
    /// # Output
    /// A tuple of the data encoded into the logical register, and the auxillary
    /// qubits used to represent the syndrome.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.LogicalRegister
    /// - Microsoft.Quantum.Canon.BitFlipEncoder
    operation BitFlipDecoder(logicalRegister : LogicalRegister)  : (Qubit[], Qubit[])
    {
        body {
            let physRegister = [logicalRegister[0]];
            let auxQubits = logicalRegister[1..2];

            (Adjoint BFEncoderImpl)(false, physRegister, auxQubits);

            return (physRegister, auxQubits);
        }
    }

    /// # Summary
    /// Returns a QECC value representing the ⟦3, 1, 1⟧ bit flip code encoder and
    /// decoder with in-place syndrome measurement.
    ///
    /// # Output
    /// Returns an implementation of a quantum error correction code by 
    /// specifying a `QECC` type.
    operation  BitFlipCode()  : QECC
    {
        body {
            let e = EncodeOp(BitFlipEncoder);
            let d = DecodeOp(BitFlipDecoder);
            let s = SyndromeMeasOp(MeasureStabilizerGenerators([
                [PauliZ; PauliZ; PauliI];
                [PauliI; PauliZ; PauliZ]
            ], _, MeasureWithScratch));
            let code = QECC(e, d, s);
            return code;
        }
    }

    /// # Summary
    /// Function for recovery Pauli operations for given symdrome measurement
    /// by table lookup for the ⟦3, 1, 1⟧ bit flip code.
    ///
    /// # Output
    /// Function of type `RecoveryFn` that takes a syndrome measurement 
    /// `Result[]` and returns the `Pauli[]` operations that corrects the 
    /// detected error.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.RecoveryFn
    function BitFlipRecoveryFn()  : RecoveryFn
    {
        return TableLookupRecovery([
            [PauliI; PauliI; PauliI];
            [PauliX; PauliI; PauliI];
            [PauliI; PauliI; PauliX];
            [PauliI; PauliX; PauliI]
        ]);
    }

}
