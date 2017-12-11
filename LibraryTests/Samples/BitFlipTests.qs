// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

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
