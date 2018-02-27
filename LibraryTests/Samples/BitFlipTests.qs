// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Samples.BitFlipCode;

    operation BitFlipSampleParityTest() : ()  {
        body {
            CheckBitFlipCodeStateParity();
        }
    }

    operation BitFlipSampleWt1CorrectionTest() : ()  {
        body {
            CheckBitFlipCodeCorrectsBitFlipErrors();
        }
    }

    operation BitFlipSampleWCanonTest() : () {
        body {
            CheckCanonBitFlipCodeCorrectsBitFlipErrors();
        }
    }
}
