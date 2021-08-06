// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace BitFlipCode {

    open Microsoft.Quantum.Samples.BitFlipCode;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation Program () : Unit {

        // We call the CheckBitFlipCodeStateParity
        // operation defined in BitFlipCode. This operation encodes
        // into a bit-flip code, such that
        //
        //     α |0〉 + β |1〉
        //
        // is encoded into
        //
        //     α |000〉 + β |111〉,
        //
        // then ensures that the parity measurements Z₀Z₁ and
        // Z₁Z₂ both return the result Zero, indicating the eigenvalue
        // (-1)⁰ is positive.

        // This check is implemented as a sequence of assertions.
        // Since we are using a target machine which supports assertions,
        // this implies that if flow control continues past the operation
        // invocation, then all of the relevant checks have passed.

        CheckBitFlipCodeStateParity();
        Message("Parity check passed successfully!");
        
        // We call the operation
        // CheckBitFlipCodeCorrectsBitFlipErrors to check that the bit-
        // flip code actually protects against bit-flip errors.
        // As before, this operation fails if an error is not corrected
        // properly. In the UnitTesting sample, we will see how to
        // represent this pattern in terms of unit tests.

        CheckBitFlipCodeCorrectsBitFlipErrors();
        Message("Corrected all three bit-flip errors successfully!");

        // In this region, we repeat the check from above, this time using
        // operations and data types from the canon to allow us to
        // represent other codes.

        CheckCanonBitFlipCodeCorrectsBitFlipErrors();
        Message("Corrected all three bit-flip errors successfully!");
    }
}
