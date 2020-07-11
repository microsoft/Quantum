// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {

    open Microsoft.Quantum.Samples.BitFlipCode;

    operation BitFlipSampleParityTest () : Unit {
        CheckBitFlipCodeStateParity();
    }


    operation BitFlipSampleWt1CorrectionTest () : Unit {
        CheckBitFlipCodeCorrectsBitFlipErrors();
    }


    operation BitFlipSampleWCanonTest () : Unit {
        CheckCanonBitFlipCodeCorrectsBitFlipErrors();
    }

}


