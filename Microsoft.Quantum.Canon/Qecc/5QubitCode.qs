// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;

    /// # Summary
    /// Private operation used to implement both the 5 qubit encoder and decoder.
    ///
    /// # Input
    /// ## data
    /// an array holding 1 qubit which is the input qubit.
    /// ## scratch
    /// an array holding 4 qubits which add redundancy.
    ///
    /// # Remarks
    /// The particular encoder chosen was taken from the paper V. Kliuchnikov and D. Maslov, "Optimization of Clifford Circuits," 
    /// Phys. Rev. Phys. Rev. A 88, 052307 (2013); https://arxiv.org/abs/1305.0810, Figure 4b) and requires a total of 11 gates.
    operation FiveQubitCodeEncoderImpl(data : Qubit[], scratch : Qubit[])  : ()
    {
        body {
            (Controlled(X))(data, scratch[1]);
            H(data[0]);
            H(scratch[0]);
            (Controlled(X))(data, scratch[2]);
            (Controlled(X))([scratch[0]], data[0]);
            (Controlled(X))(data, scratch[1]);
            (Controlled(X))([scratch[0]], scratch[3]);
            H(scratch[0]);
            H(data[0]);
            (Controlled(X))([scratch[0]], scratch[2]);
            (Controlled(X))(data, scratch[3]);
            // The last X below is to correct the signs of stabilizers.
            // The 5-qubit code is non-CSS, so even if the circuit implements
            // the correct symplectic matrix,
            // it may differ from the desired one by a Pauli correction.
            X(scratch[2]);
        }

        adjoint auto
    }

    /// # Summary
    /// Returns function that maps error syndrome measurements to the
    /// appropriate error-correcting Pauli operators by table lookup for
    /// the ⟦5, 1, 3⟧ quantum code.
    ///
    /// # Output
    /// Function of type `RecoveryFn` that takes a syndrome measurement
    /// `Result[]` and returns the `Pauli[]` operators that corrects the
    /// detected error.
    ///
    /// # Remarks
    /// By iterating over all errors of weight $1$, we obtain a total of $3\times 5=15$ possible non-trivial syndromes.
    /// Together with the identity, a table of error and corresponding syndrom is built up. For the 5 qubit code
    /// this table is given by: $X\_1: (0,0,0,1); X\_2: (1,0,0,0); X\_3: (1,1,0,0); X\_4: (0,1,1,0); X\_5: (0,0,1,1),
    /// Z\_1: (1,0,1,0); Z\_2: (0,1,0,1); Z\_3: (0,0,1,0); Z\_4: (1,0,0,1); Z\_5: (0,1,0,0)$ with $Y_i$ obtained by adding the $X_i$ and $Z_i$ syndromes. Note that the 
    /// ordering in the table lookup recovery is given by converting the bitvectors to integers (using little endian).
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.RecoveryFn
    function  FiveQubitCodeRecoveryFn()  : RecoveryFn
    {
        return TableLookupRecovery(
            [ [PauliI; PauliI; PauliI; PauliI; PauliI]; 
            [PauliI; PauliX; PauliI; PauliI; PauliI]; 
            [PauliI; PauliI; PauliI; PauliI; PauliZ]; 
            [PauliI; PauliI; PauliX; PauliI; PauliI]; 
            [PauliI; PauliI; PauliZ; PauliI; PauliI]; 
            [PauliZ; PauliI; PauliI; PauliI; PauliI]; 
            [PauliI; PauliI; PauliI; PauliX; PauliI]; 
            [PauliI; PauliI; PauliY; PauliI; PauliI]; 
            [PauliX; PauliI; PauliI; PauliI; PauliI]; 
            [PauliI; PauliI; PauliI; PauliZ; PauliI]; 
            [PauliI; PauliZ; PauliI; PauliI; PauliI]; 
            [PauliI; PauliY; PauliI; PauliI; PauliI]; 
            [PauliI; PauliI; PauliI; PauliI; PauliX]; 
            [PauliY; PauliI; PauliI; PauliI; PauliI]; 
            [PauliI; PauliI; PauliI; PauliI; PauliY]; 
            [PauliI; PauliI; PauliI; PauliY; PauliI] ]
        );
    }

    /// # Summary
    /// Encodes into the ⟦5, 1, 3⟧ quantum code. 
    ///
    /// # Input
    /// ## physRegister
    /// A qubit representing an unencoded state. This array `Qubit[]` is of 
    /// length 1.
    /// ## auxQubits
    /// A register of auxillary qubits that will be used to represent the
    /// encoded state.
    ///
    /// # Output
    /// An array of physical qubits of type `LogicalRegister` that store the
    /// encoded state. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.LogicalRegister
    operation FiveQubitCodeEncoder(physRegister : Qubit[], auxQubits : Qubit[])  : LogicalRegister
    {
        body {
            FiveQubitCodeEncoderImpl(physRegister, auxQubits);
            
            let logicalRegister = LogicalRegister(physRegister + auxQubits);
            return logicalRegister;
        }
    }

    /// # Summary
    /// Decodes the ⟦5, 1, 3⟧ quantum code. 
    ///
    /// # Input
    /// ## logicalRegister
    /// An array of qubits representing the encoded 5-qubit code logical state.
    ///
    /// # Output
    /// A qubit array of length 1 representing the unencoded state in the 
    /// first parameter, together with auxillary qubits in the second parameter.
    ///
    /// # See Also
    /// - microsoft.quantum.canon.FiveQubitCodeEncoder
    /// - Microsoft.Quantum.Canon.LogicalRegister
    operation FiveQubitCodeDecoder( logicalRegister : LogicalRegister)  : (Qubit[], Qubit[])
    {
        body {
            let physRegister = [logicalRegister[0]];
            let auxQubits = logicalRegister[1..4];

            (Adjoint FiveQubitCodeEncoderImpl)(physRegister, auxQubits);

            return (physRegister, auxQubits);
        }
    }

    /// # Summary
    /// Returns a QECC value representing the ⟦5, 1, 3⟧ code encoder and
    /// decoder with in-place syndrome measurement.
    ///
    /// # Output
    /// Returns an implementation of a quantum error correction code by 
    /// specifying a `QECC` type.
    ///
    /// # Remarks
    /// This code was found independently in the following two papers:
    /// - C. H. Bennett, D. DiVincenzo, J. A. Smolin and W. K. Wootters, "Mixed state entanglement and quantum error correction," Phys. Rev. A, 54 (1996) pp. 3824-3851; https://arxiv.org/abs/quant-ph/9604024 and
    /// - R. Laflamme, C. Miquel, J. P. Paz and W. H. Zurek, "Perfect quantum error correction code," Phys. Rev. Lett. 77 (1996) pp. 198-201; https://arxiv.org/abs/quant-ph/9602019
    operation  FiveQubitCode()  : QECC
    {
        body {
            let e = EncodeOp(FiveQubitCodeEncoder);
            let d = DecodeOp(FiveQubitCodeDecoder);
            let s = SyndromeMeasOp(MeasureStabilizerGenerators(
                        [ [ PauliX; PauliZ; PauliZ; PauliX; PauliI ]; 
                        [ PauliI; PauliX; PauliZ; PauliZ; PauliX ];
                        [ PauliX; PauliI; PauliX; PauliZ; PauliZ ];
                        [ PauliZ; PauliX; PauliI; PauliX; PauliZ ] ],
                        _, MeasureWithScratch)
                    );
            let code = QECC(e, d, s);
            return code;
        }
    }

}
