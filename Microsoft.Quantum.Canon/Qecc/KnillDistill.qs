// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;

    /// # Summary
    /// Syndrome measurement and the inverse of embedding.
    /// $X$- and $Z$-stabilizers are not treated equally,
    /// which is due to the particular choice of the encoding circuit.
    /// This asymmetry leads to a different syndrome extraction routine.
    /// One could measure the syndrome by measuring multi-qubit Pauli operator
    /// directly on the code state, but for the distillation purpose
    /// the logical qubit is returned into a single qubit,
    /// in course of which the syndrome measurements can be done without further ancillas.
    ///
    /// # Output
    /// The logical qubit and a pair of integers for $X$-syndrome and $Z$-syndrome.
    /// They represent the index of the code qubit on which a single $X$- or $Z$-error
    /// would have caused the measured syndrome.
    ///
    /// # Remarks
    /// > [!WARNING]
    /// > This routine is tailored 
    /// > to a particular encoding circuit for Steane's 7 qubit code;
    /// > if the encoding circuit is modified then the syndrome outcome
    /// > might have to be interpreted differently.
    operation _ExtractLogicalQubitFromSteaneCode(code: LogicalRegister) : (Qubit, Int, Int)
    {
        body {
            (Adjoint SteaneCodeEncoderImpl)(code[0..0], code[1..6]);

            let x0 = M( code[6] );
            let x1 = M( code[1] );
            let x2 = M( code[3] );

            mutable xsyn = 0;
            if( x0 == One ) { set xsyn = xsyn ^^^ 1; }
            if( x1 == One ) { set xsyn = xsyn ^^^ 2; }
            if( x2 == One ) { set xsyn = xsyn ^^^ 4; }
            set xsyn = xsyn - 1;
            // xsyn contains the qubit index (0..6) at which a single Z-error would
            // produce the given syndrome.

            let z0 = M(code[5]);
            let z1 = M(code[2]);
            let z2 = M(code[4]);

            mutable zsyn = 0;
            if( z0 == One ) { set zsyn = zsyn ^^^ 1; }
            if( z1 == One ) { set zsyn = zsyn ^^^ 2; }
            if( z2 == One ) { set zsyn = zsyn ^^^ 5; }
            set zsyn = zsyn - 1;
            // zsyn contains the qubit index (0..6) at which a single X-error would
            // produce the given syndrome.

            return (code[0], xsyn, zsyn);
        }
    }

    /// # Summary
    /// Performs a $\pi / 4$ rotation about $Y$ by consuming a magic
    /// state; that is, a copy of the state
    /// $$
    /// \begin{align}
    ///     \cos\frac{\pi}{8} \ket{0} + \sin \frac{\pi}{8} \ket{1}.
    /// \end{align}
    /// $$.
    ///
    /// # Input
    /// ## data
    /// A qubit to be rotated about $Y$ by $\pi / 4$.
    ///
    /// ## magic
    /// A qubit initially in the magic state. Following application
    /// of this operation, `magic` is returned to the $\ket{0}$ state.
    ///
    /// # Remarks
    /// The following are equivalent:
    /// ```Q#
    /// Ry(PI() / 4.0, data);
    ///
    /// using (magicRegister = Qubit[1]) {
    ///     let magic = magicRegister[0];
    ///     Ry(PI() / 4.0, magic);
    ///     InjectPi4YRotation(data, magic);
    ///     Reset(magic);
    /// }
    /// ```
    ///
    /// This operation supports the `Adjoint` functor, in which
    /// case the same magic state is consumed, but the effect
    /// on the data qubit is a $-\pi/4$ $Y$-rotation.
    operation InjectPi4YRotation(data: Qubit, magic: Qubit) : ()
    {
        body {
            (Adjoint S)(data);
            CNOT(magic, data);
            S(data);
            let r = MResetY(magic);
            if ( r == One ) {
                // The following five gates is equal to	Ry( Pi()/2.0, data)
                // up to global phase.
                S(data);
                H(data);
                (Adjoint S)(data);
                H(data);
                (Adjoint S)(data);
            }
        }
        adjoint {
            (Adjoint S)(data);
            CNOT(magic, data);
            S(data);
            let r = MResetY(magic);
            if ( r == Zero ) {
                S(data);
                H(data);
                S(data);
                H(data);
                (Adjoint S)(data);
            }
        }
    }

    /// # Summary
    /// Given 15 approximate copies of a magic state
    /// $$
    /// \begin{align}
    ///     \cos\frac{\pi}{8} \ket{0} + \sin \frac{\pi}{8} \ket{1}.
    /// \end{align},
    /// $$ yields one higher-quality copy.
    ///
    /// # Input
    /// ## roughMagic
    /// A register of fifteen qubits containing approximate copies
    /// of a magic state. Following application of this distillation
    /// procedure, `roughMagic[0]` will contain one higher-quality
    /// copy, and the rest of the register will be reset to the
    /// $\ket{00\cdots 0}$ state.
    ///
    /// # Output
    /// If `true`, then the procedure succeeded and the higher-quality
    /// copy should be accepted. If `false`, the procedure failed, and
    /// the state of the register should be considered undefined.
    ///
    /// # Remarks
    /// We follow the algorithm of Knill.
    /// However, the present implementation is far from being optimal,
    /// as it uses too many qubits.
    /// The magic states are injected in this routine,
    /// in which case there are better protocols.
    ///
    /// # References
    /// - [Knill](https://arxiv.org/abs/quant-ph/0402171)
    operation KnillDistill( roughMagic : Qubit[] ) : ( Bool )
    {
        body {
            mutable accept = false;
            using (scratch = Qubit[8]) {
                let anc = scratch[7];
                let code = scratch[0..6];
                InjectPi4YRotation( code[0], roughMagic[14] );
                SteaneCodeEncoderImpl( code[0..0], code[1..6] );
                for ( idx in 0..6 ) {
                    (Adjoint InjectPi4YRotation)( code[idx], roughMagic[idx] );
                    CNOT(code[idx], anc);
                    InjectPi4YRotation(code[idx], roughMagic[idx + 7]);
                }
                let (logicalQubit, xsyn, zsyn) =
                    _ExtractLogicalQubitFromSteaneCode(LogicalRegister(code));
                let m = M(anc);
                if( xsyn == -1 && zsyn == -1 && m == Zero ) {
                    SWAP(logicalQubit, roughMagic[0]);
                    set accept = true;
                }

                ResetAll(scratch);
            }
            return accept;
        }
    }

}
