// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Samples.BitFlipCode;
    open Microsoft.Quantum.Diagnostics;

    @Test("QuantumSimulator")
    operation TestBitFlipSampleParity() : Unit {
        CheckBitFlipCodeStateParity();
    }

    @Test("QuantumSimulator")
    operation TestBitFlipSampleWt1Correction() : Unit {
        CheckBitFlipCodeCorrectsBitFlipErrors();
    }

    @Test("QuantumSimulator")
    operation TestBitFlipSampleWCanon() : Unit {
        CheckCanonBitFlipCodeCorrectsBitFlipErrors();
    }

}
