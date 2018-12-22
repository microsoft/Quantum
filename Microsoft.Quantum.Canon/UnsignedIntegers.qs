// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


///////////////////////////////////////////////////////////////////////////////////////////
// Types and supporting functions for representing unsigned integers in arrays of qubits //
///////////////////////////////////////////////////////////////////////////////////////////

namespace Microsoft.Quantum.Canon {

    open Microsoft.Quantum.Primitive;

    /// # Summary
    /// Register that encodes an unsigned integer in little-endian order. The
    /// qubit with index `0` encodes the lowest bit of an unsigned integer
    ///
    /// # Remarks
    /// We abbreviate `LittleEndian` as `LE` in the documentation.
    newtype LittleEndian = Qubit[];

    /// # Summary
    /// Register that encodes an unsigned integer in big-endian order. The
    /// qubit with index `0` encodes the highest bit of an unsigned integer
    ///
    /// # Remarks
    /// We abbreviate `BigEndian` as `BE` in the documentation.
    newtype BigEndian = Qubit[];

    /// # Summary 
    /// Little-endian unsigned integers in QFT basis. 
    /// For example, if |x⟩ is little-endian encoding of integer x in computational basis, 
    /// then QFTLE|x⟩ is encoding of x in QFT basis. 
    ///
    /// # Remarks
    /// We abbreviate `LittleEndian` as `LE` in the documentation. 
    ///
    /// # See Also
    /// - microsoft.quantum.canon.qft
    /// - microsoft.quantum.canon.qftle
    newtype PhaseLittleEndian = (Qubit[]);

    /// # Summary
    /// Applies an operation that takes little-endian input to a register encoding 
    /// an unsigned integer using big-endian format.
    ///
    /// # Input
    /// ## op
    /// Operation that acts on a little-endian register.
    /// ## register
    /// A big-endian register to be transformed.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyReversedOpLittlEndianA
    /// - Microsoft.Quantum.Canon.ApplyReversedOpLittlEndianC
    /// - Microsoft.Quantum.Canon.ApplyReversedOpLittlEndianCA
    operation ApplyReversedOpLittleEndian( 
              op : (LittleEndian => ()),
              register : BigEndian)  : ()
    {
        body {
            let bareReversed = Reverse(AsQubitArray(register));
            let reversed = LittleEndian(bareReversed);
            op(reversed);
        }
    }

    /// # Summary
    /// Applies an operation that takes little-endian input and that supports
    /// the adjoint functor to a register encoding 
    /// an unsigned integer using big-endian format.
    ///
    /// # See Also 
    /// - @"microsoft.quantum.canon.applyreversedoplittleendian"
    operation ApplyReversedOpLittleEndianA( 
              op : (LittleEndian => () : Adjoint),  
              register : BigEndian)  : ()
    {
        body {
            let bareReversed = Reverse(AsQubitArray(register));
            let reversed = LittleEndian(bareReversed);
            op(reversed);
        }
        adjoint auto
    }

    /// # Summary
    /// Applies an operation that takes little-endian input and that supports
    /// the controlled functor to a register encoding 
    /// an unsigned integer using big-endian format.
    ///
    /// # See Also 
    /// - @"microsoft.quantum.canon.applyreversedoplittleendian"
    operation ApplyReversedOpLittleEndianC(
              op : (LittleEndian => () : Controlled),
              register : BigEndian )  : ()
    {
        body {
            let bareReversed = Reverse(AsQubitArray(register));
            let reversed = LittleEndian(bareReversed);
            op(reversed);
        }
        controlled auto
    }

    /// # Summary
    /// Applies an operation that takes little-endian input and that supports
    /// the controlled and adjoint functors to a register encoding 
    /// an unsigned integer using big-endian format.
    ///
    /// # See Also 
    /// - @"microsoft.quantum.canon.applyreversedoplittleendian"
    operation ApplyReversedOpLittleEndianCA(
              op : (LittleEndian => () : Controlled, Adjoint),  
              register : BigEndian)  : ()
    {
        body {
            let bareReversed = Reverse(AsQubitArray(register));
            let reversed = LittleEndian(bareReversed);
            op(reversed);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Applies an operation that takes big-endian input to a register encoding
    /// an unsigned integer using little-endian format.
    ///
    /// # Input
    /// ## op
    /// Operation that acts on big-endian register
    /// ## register
    /// little-endian register to be transformed
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.applyreversedopbigendiana"
    /// - @"microsoft.quantum.canon.applyreversedopbigendianc"
    /// - @"microsoft.quantum.canon.applyreversedopbigendianca"
    operation ApplyReversedOpBigEndian(
              op : (BigEndian => ()),
              register : LittleEndian)  : ()
    {
        body {
            let bareReversed = Reverse(AsQubitArray(register));
            let reversed = BigEndian(bareReversed);
            op(reversed);
        }
    }

    /// # See Also
    /// - @"microsoft.quantum.canon.applyreversedopbigendian"
    operation ApplyReversedOpBigEndianA(
              op : (BigEndian => () : Adjoint),
              register : LittleEndian)  : ()
    {
        body {
            let bareReversed = Reverse(AsQubitArray(register));
            let reversed = BigEndian(bareReversed);
            op(reversed);
        }
        adjoint auto
    }

    /// # See Also 
    /// - @"microsoft.quantum.canon.applyreversedopbigendian"
    operation ApplyReversedOpBigEndianC(
              op : (BigEndian => () : Controlled),
              register : LittleEndian)  : ()
    {
        body {
            let bareReversed = Reverse(AsQubitArray(register));
            let reversed = BigEndian(bareReversed);
            op(reversed);
        }
        controlled auto
    }

    /// # See Also 
    /// - @"microsoft.quantum.canon.applyreversedopbigendian"
    operation ApplyReversedOpBigEndianCA(
              op : (BigEndian => () : Controlled, Adjoint),
              register : LittleEndian)  : ()
    {
        body {
            let bareReversed = Reverse(AsQubitArray(register));
            let reversed = BigEndian(bareReversed);
            op(reversed);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Uses SWAP gates to reverse the order of the qubits in
    /// a register.
    ///
    /// # Input
    /// ## register
    /// The qubits order of which should be reversed using SWAP gates
    operation SwapReverseRegister(register : Qubit[])  : ()
    {
        body {
            let totalQubits = Length(register);
            let halfTotal = totalQubits / 2;
            for( i in 0 .. halfTotal - 1 ) {
                SWAP(register[i],register[ totalQubits - i - 1 ]);
            }
        }
        adjoint self
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Applies an operation that takes a
    /// <xref:microsoft.quantum.canon.littleendian> register as input
    /// on a target register of type <xref:microsoft.quantum.canon.phaselittleendian>.
    ///
    /// # Input
    /// ## op
    /// The operation to be applied.
    /// ## target
    /// The register to which the operation is applied.
    ///
    /// # Remarks
    /// The register is transformed to `PhaseLittleEndian` by the use of
    /// <xref:microsoft.quantum.canon.qftle> and is then returned to
    /// its original representation after application of `op`.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyPhaseLEOperationOnLEA
    /// - Microsoft.Quantum.Canon.ApplyPhaseLEOperationOnLEA
    /// - Microsoft.Quantum.Canon.ApplyPhaseLEOperationOnLECA
    operation ApplyPhaseLEOperationOnLE( op : (PhaseLittleEndian => ()), target : LittleEndian ) : () {
        body {
            QFTLE(target);
            let phaseLE = PhaseLittleEndian(target);
            op(phaseLE);
            (Adjoint QFTLE)(target);
        }
    }
    
    /// # See Also
    /// - @"microsoft.quantum.canon.applyphaseleoperationonle"
    operation ApplyPhaseLEOperationOnLEA( op : (PhaseLittleEndian => () : Adjoint), target : LittleEndian ) : () {
        body {
            QFTLE(target);
            let phaseLE = PhaseLittleEndian(target);
            op(phaseLE);
            (Adjoint QFTLE)(target);
        }
        adjoint auto
    }

    /// # See Also 
    /// - @"microsoft.quantum.canon.applyphaseleoperationonle"
    operation ApplyPhaseLEOperationOnLEC( op : (PhaseLittleEndian => () : Controlled), target : LittleEndian ) : () {
        body {
            QFTLE(target);
            let phaseLE = PhaseLittleEndian(target);
            op(phaseLE);
            (Adjoint QFTLE)(target);
        }
        controlled( controls ) {
            QFTLE(target);
            let phaseLE = PhaseLittleEndian(target);
            (Controlled op)(controls, phaseLE);
            (Adjoint QFTLE)(target);
        }
    }

    /// # See Also 
    /// - @"microsoft.quantum.canon.applyphaseleoperationonle"
    operation ApplyPhaseLEOperationOnLECA( op : (PhaseLittleEndian => () : Controlled, Adjoint), target : LittleEndian ) : () {
        body {
            QFTLE(target);
            let phaseLE = PhaseLittleEndian(target);
            op(phaseLE);
            (Adjoint QFTLE)(target);
        }
        adjoint auto
        controlled( controls ) {
            QFTLE(target);
            let phaseLE = PhaseLittleEndian(target);
            (Controlled op)(controls, phaseLE);
            (Adjoint QFTLE)(target);
        }
        controlled adjoint auto
    }

    /// # Summary
    /// Applies an operation that takes a
    /// <xref:microsoft.quantum.canon.phaselittleendian> register as input
    /// on a target register of type <xref:microsoft.quantum.canon.littleendian>.
    ///
    /// # Input
    /// ## op
    /// The operation to be applied.
    /// ## target
    /// The register to which the operation is applied.
    ///
    /// # Remarks
    /// The register is transformed to `LittleEndian` by the use of
    /// <xref:microsoft.quantum.canon.qftle> and is then returned to
    /// its original representation after application of `op`.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyLEOperationOnPhaseLEA
    /// - Microsoft.Quantum.Canon.ApplyLEOperationOnPhaseLEA
    /// - Microsoft.Quantum.Canon.ApplyLEOperationOnPhaseLECA
    operation ApplyLEOperationOnPhaseLE( op : (LittleEndian => ()), target : PhaseLittleEndian ) : () {
        body {
            let targetLE = LittleEndian(target);
            With(Adjoint(QFTLE),op,targetLE);
        }
    }

    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyLEOperationOnPhaseLE
    operation ApplyLEOperationOnPhaseLEA( op : (LittleEndian => () : Adjoint), target : PhaseLittleEndian ) : () {
        body {
            let targetLE = LittleEndian(target);
            WithA(Adjoint(QFTLE),op,targetLE);
        }
        adjoint auto
    }

    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyLEOperationOnPhaseLE
    operation ApplyLEOperationOnPhaseLEC( op : (LittleEndian => () : Controlled), target : PhaseLittleEndian ) : () {
        body {
            let targetLE = LittleEndian(target);
            WithC(Adjoint(QFTLE),op,targetLE);
        }
        controlled auto
    }

    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyLEOperationOnPhaseLE
    operation ApplyLEOperationOnPhaseLECA( op : (LittleEndian => () : Controlled, Adjoint ), target : PhaseLittleEndian ) : () {
        body {
            let targetLE = LittleEndian(target);
            WithCA(Adjoint(QFTLE),op,targetLE);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }
}
