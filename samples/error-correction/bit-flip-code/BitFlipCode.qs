// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.BitFlipCode {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.ErrorCorrection;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;


    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // In this sample, we build on the discussion in the quantum error
    // correction section of the developers' guide:

    //     https://docs.microsoft.com/azure/quantum/user-guide/libraries/standard/error-correction

    // In particular, we start by manually encoding into the bit-flip code.
    // We then show how operations and functions provided in the Q# canon
    // allow us to easily model error correction in a way that immediately
    // generalizes to other codes.

    //////////////////////////////////////////////////////////////////////////
    // The Bit-Flip Code /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // The bit-flip code protects against any one bit-flip (X) error on three
    // qubits by mapping |0〉 to |̅0〉 ≔ |000〉 and |1〉 to |̅1〉 ≔ |111〉. By
    // linearity, any other state |ψ〉 = α|0〉 + β|1〉 is represented by the
    // logical state

    //     |̅ψ〉 ≔ α |̅0〉 + β |̅1〉
    //         = α |000〉 + β |111〉.

    // We start by defining an operation which implements an encoder for
    // this code. To do so, note that CNOT allows us to "copy" classical
    // information in the bitstrings used to label computational basis
    // elements:

    //     CNOT |b0〉 = |bb〉,

    // where b ∈ {0, 1}. This is not the same as copying the state, since
    // CNOT acts linearly:

    //     CNOT (α |0〉 + β |1〉) ⊗ |0〉 = α |00〉 + β |11〉.

    // That is, consistent with the no-cloning theorem, CNOT did not
    // copy our arbitrary input state. On the other hand, this is
    // precisely the transformation that we want here:

    //    CNOT₀₂ · CNOT₀₁ (α |0〉 + β |1〉) ⊗ |00〉
    //        = α |000〉 + β |111〉
    //        = α |̅0〉 + β |̅1〉.

    // Thus, we can write out our encoder in a very simple form:

    /// # Summary
    /// Given a qubit representing a state to be protected and two auxiliary
    /// qubits initially in the |0〉 state, encodes the state into the
    /// three-qubit bit-flip code.
    ///
    /// # Input
    /// ## data
    /// A qubit whose state is to be protected.
    /// ## auxiliaryQubits
    /// Two qubits, initially in the |00〉 state, to be used in protecting
    /// the state of `data`.
    operation EncodeIntoBitFlipCode (data : Qubit, auxiliaryQubits : Qubit[]) : Unit
        // Since decoding is the adjoint of encoding, we must
        // denote that this operation supports the Adjoint
        // functor.
        is Adj + Ctl
    {
        // We use the ApplyToEach operation from the canon,
        // partially applied with the data qubit, to represent
        // a "CNOT-ladder." In this case, the line below
        // applies CNOT₀₁ · CNOT₀₂.
        ApplyToEachCA(CNOT(data, _), auxiliaryQubits);
    }

    // As a quick example, we will check that after encoding, the parity of
    // each pair of qubits is positive (corresponding to the Zero) Result,
    // such that we can learn syndrome information without revealing
    // the state of an encoded qubit.

    /// # Summary
    /// This operation encodes into a bit-flip code, and confirms that
    /// the parity measurements Z₀Z₁ and Z₁Z₂ both return positive eigenvalues
    /// (that is, the Result value Zero) without disturbing the state that
    /// we are trying to protect.
    ///
    /// # Remarks
    /// This operation will fail when the parity checks are incorrect
    /// if run on a target machine which supports assertions, and thus
    /// can be used as a unit test of error-correction functionality.
    operation CheckBitFlipCodeStateParity () : Unit {

        // We start by preparing R_x(π / 3) |0〉 as our
        // test state, along with two auxiliary qubits in the |00〉
        // state that we can use to encode.
        use data = Qubit();
        use auxiliaryQubits = Qubit[2];
        let register = [data] + auxiliaryQubits;
        Rx(PI() / 3.0, data);

        // Next, we encode our test state.
        EncodeIntoBitFlipCode(data, auxiliaryQubits);

        // At this point, register represents a code block
        // that protects the state R_x(π / 3) |0〉.
        // We should thus be able to measure Z₀Z₁ and Z₁Z₂
        // without disturbing the code state.
        // To check this, we proceed in two steps:

        //     • Use Assert to ensure that the measurement
        //       will return Zero.
        //     • Use M to actually perform the measurement.

        // If our target machine is a simulator, the first step
        // will cause our quantum program to crash if the assertion
        // fails. Since an assertion is not a physical operation,
        // the state of the qubits that we pass to Assert are not
        // disturbed. If our target machine is an actual quantum
        // processor, then the assertion will be skipped with no
        // further effect.
        AssertMeasurement([PauliZ, PauliZ, PauliI], register, Zero, "Z₀Z₁ was One!");
        AssertMeasurement([PauliI, PauliZ, PauliZ], register, Zero, "Z₁Z₂ was One!");

        // The second step then actually performs the measurement,
        // showing that we can make parity measurements without
        // disturbing the state that we care about.
        let parity01 = Measure([PauliZ, PauliZ, PauliI], register);
        let parity12 = Measure([PauliI, PauliZ, PauliZ], register);

        // To check that we have not disturbed the state, we decode,
        // rotate back, and assert once more.
        Adjoint EncodeIntoBitFlipCode(data, auxiliaryQubits);
        Adjoint Rx(PI() / 3.0, data);
        AssertMeasurement([PauliZ], [data], Zero, "Didn't return to |0〉!");
    }


    // Now that we're assured we can measure Z₀Z₁ and Z₁Z₂ without disturbing
    // the state of interest, let's use that to actually extract a syndrome
    // and recover from a bit-flip error.

    // Starting with the previous operation as a template, we'll remove
    // the assertions for the parity checks and allow for an error operation
    // to be passed as an input, then will modify it to use `parity01` and
    // `parity12` to perform the correction.

    // To take an error operation as an argument, we declare an input
    // of type (Qubit[] => ()), representing something that can happen
    // to an array of qubits. That is, we take the error to be applied
    // in a black-box sense.

    /// # Summary
    /// This operation encodes into a bit-flip code, and confirms that
    /// it can correct a given error applied to the logical state
    /// that results from encoding R_x(π / 3) |0〉.
    ///
    /// # Input
    /// ## error
    /// An operation representing an error to be applied to the code
    /// block.
    ///
    /// # Remarks
    /// This operation will fail when the error correction step fails
    /// if run on a target machine which supports assertions, and thus
    /// can be used as a unit test of error-correction functionality.
    operation CheckBitFlipCodeCorrectsError(error : (Qubit[] => Unit)) : Unit {
        use data = Qubit();
        use auxiliaryQubits = Qubit[2];
        let register = [data] + auxiliaryQubits;

        // We start by proceeding the same way as above
        // in order to obtain the code block state |̅ψ〉.
        Rx(PI() / 3.0, data);
        EncodeIntoBitFlipCode(data, auxiliaryQubits);

        // Next, we apply the error that we've been given to the
        // entire register.
        error(register);

        // We measure the two parities Z₀Z₁ and Z₁z₂ as before
        // to obtain our syndrome.
        let parity01 = Measure([PauliZ, PauliZ, PauliI], register);
        let parity12 = Measure([PauliI, PauliZ, PauliZ], register);

        // To use the syndrome obtained above, we recall the table
        // from <https://docs.microsoft.com/azure/quantum/user-guide/libraries/standard/error-correction>:

        //     Error | Z₀Z₁ | Z₁Z₂
        //     ===================
        //       1   | Zero | Zero
        //       X₀  |  One | Zero
        //       X₁  |  One |  One
        //       X₂  | Zero |  One

        // Since the recovery is a classical inference procedure, we
        // can represent it here by using if/elif statements:
        if (parity01 == One and parity12 == Zero) {
            X(register[0]);
        }
        elif (parity01 == One and parity12 == One) {
            X(register[1]);
        }
        elif (parity01 == Zero and parity12 == One) {
            X(register[2]);
        }

        // To check that we have not disturbed the state, we decode,
        // rotate back, and assert once more.
        Adjoint EncodeIntoBitFlipCode(data, auxiliaryQubits);
        Adjoint Rx(PI() / 3.0, data);
        AssertMeasurement([PauliZ], [data], Zero, "Didn't return to |0〉!");
    }


    // Now that we have defined an operation which fails if the bit-flip
    // code fails to protect a state from a given error, we can call it
    // with the specific errors that the bit-flip code can correct.
    // To do so, it is helpful to use the ApplyPauli operation from
    // the canon, which takes an array of Pauli values and applies the
    // corresponding sequence of operation.

    // For example,

    //     ApplyPauli([PauliX, PauliY, PauliZ, PauliI], register);

    // is equivalent to

    //     X(register[0]);
    //     Y(register[1]);
    //     Z(register[2]);

    // If we partially apply ApplyPauli, we get an operation that
    // represents applying a specific multi-qubit Pauli operator.
    // For instance,

    //     ApplyPauli([PauliX, PauliI, PauliI], _)

    // is an operation of type (Qubit[] => ()) that represents
    // the X₀ bit-flip error.

    /// # Summary
    /// For each single-qubit bit-flip error on three qubits, this operation
    /// encodes R_x(π / 3) |0〉 into the bit-flip code and asserts that the
    /// code protects against that error.
    ///
    /// # Remarks
    /// This operation will fail when error correction fails
    /// if run on a target machine which supports assertions, and thus
    /// can be used as a unit test of error-correction functionality.
    operation CheckBitFlipCodeCorrectsBitFlipErrors() : Unit {
        // First, we declare our errors using the notation
        // described above.
        let X0 = ApplyPauli([PauliX, PauliI, PauliI], _);
        let X1 = ApplyPauli([PauliI, PauliX, PauliI], _);
        let X2 = ApplyPauli([PauliI, PauliI, PauliX], _);

        // For each of these errors, we can then check
        // that the bit flip code corrects them appropriately.
        CheckBitFlipCodeCorrectsError(X0);
        CheckBitFlipCodeCorrectsError(X1);
        CheckBitFlipCodeCorrectsError(X2);
    }


    // Finally, we show how the logic described in this sample can be
    // generalized by using functionality from the canon. This will allow
    // us to consider much more involved error-correcting codes using the
    // same interface as the bit-flip code discussed here.
    // To underscore this point, we write our new operation to take a QECC
    // value as its input, where QECC is a type provided by the canon to
    // collect all of the relevant information about an error-correcting code.

    // The canon separates the role of the classical recovery process from
    // the rest of an error-correcting code, allowing for recovery functions
    // which use prior information about error models to improve code
    // performance. Thus, we take a separate input of type RecoveryFn, a
    // canon type used to denote functions which fulfill this role.

    /// # Summary
    /// This operation encodes into an arbitrary code, and confirms that
    /// it can correct a given error applied to the logical state
    /// that results from encoding R_x(π / 3) |0〉.
    ///
    /// # Input
    /// ## error
    /// An operation representing an error to be applied to the code
    /// block.
    ///
    /// # Remarks
    /// This operation will fail when the error correction step fails
    /// if run on a target machine which supports assertions, and thus
    /// can be used as a unit test of error-correction functionality.
    operation CheckCodeCorrectsError(code : QECC, nScratch : Int, fn : RecoveryFn, error : (Qubit[] => Unit)) : Unit {

        // We once again begin by allocating some qubits to use as data
        // and auxiliary qubits, and by preparing a test state on the
        // data qubit.
        use data = Qubit();
        use auxiliaryQubits = Qubit[nScratch];
        // We start by proceeding the same way as above
        // in order to obtain the code block state |̅ψ〉.
        let register = [data] + auxiliaryQubits;

        Rx(PI() / 3.0, data);

        // We differ this time, however, in how we perform the
        // encoding. The code input provided to this operation
        // specifies an encoder, a decoder, and a syndrome
        // measurement. Deconstructing that tuple will give us access
        // to all three operations.
        let (encode, decode, syndMeas) = code!;

        // We can now encode as usual, with the slight exception
        // that the encoder returns a value of a new user-defined type
        // that marks the register as encoding a state.
        // This is simply another "view" on the same qubits, but
        // allows us to write operations which only act on code
        // blocks.
        // Note that we also pass data as an array of qubits, to
        // allow for codes which protect multiple qubits in one block.
        let codeBlock = encode!([data], auxiliaryQubits);

        // Next, we cause an error as usual.
        error(codeBlock!);

        // We can then ask the canon to perform the recovery, using
        // our classical recovery procedure along with the code of
        // interest.
        Recover(code, fn, codeBlock);

        // Having recovered, we can decode to obtain new qubit arrays
        // pointing to the decoded data and auxiliary qubits.
        let (decodedData, decodedAuxiliary) = decode!(codeBlock);

        // Finally, we test that our test state was protected.
        Adjoint Rx(PI() / 3.0, data);
        AssertMeasurement([PauliZ], [data], Zero, "Didn't return to |0〉!");
    }


    // We will now write one last test that calls the new operation with
    // the BitFlipCode and BitFlipRecoveryFn provided by the canon.
    // Try replacing these with calls to other codes provided by the
    // canon!

    /// # Summary
    /// For each single-qubit bit-flip error on three qubits, this operation
    /// encodes R_x(π / 3) |0〉 into the bit-flip code and asserts that the
    /// code protects against that error.
    ///
    /// # Remarks
    /// This operation will fail when error correction fails
    /// if run on a target machine which supports assertions, and thus
    /// can be used as a unit test of error-correction functionality.
    operation CheckCanonBitFlipCodeCorrectsBitFlipErrors() : Unit {
        let code = BitFlipCode();
        let recoveryFn = BitFlipRecoveryFn();
        let X0 = ApplyPauli([PauliX, PauliI, PauliI], _);
        let X1 = ApplyPauli([PauliI, PauliX, PauliI], _);
        let X2 = ApplyPauli([PauliI, PauliI, PauliX], _);

        // For each of these errors, we can then check
        // that the bit flip code corrects them appropriately.
        for error in [X0, X1, X2] {
            CheckCodeCorrectsError(code, 2, recoveryFn, error);
        }
    }

}
