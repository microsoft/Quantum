// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Samples.Measurement;
    open Microsoft.Quantum.Intrinsic;

    operation MeasurementTest() : Unit {
        // The use of mutables here is to enforce types.
        // Effectively, these are facts that guard against changing the signatures
        // of operations in the samples.
        mutable resOne = Zero;
        set resOne = SampleQrng();
        mutable resTwo = (Zero, Zero);
        set resTwo = MeasureTwoQubits();
        mutable resBell = (Zero, Zero);
        set resBell = MeasureInBellBasis();
    }

}
