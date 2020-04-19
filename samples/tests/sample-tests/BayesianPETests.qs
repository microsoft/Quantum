// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Samples.PhaseEstimation;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;

    operation BayesianPEManualTest() : Unit {

        let expected = 0.571;
        let actual = BayesianPhaseEstimationSample(expected);

        // Give a very generous tolerance to reduce false positive rate.
        EqualityWithinToleranceFact(expected, actual, 0.05);
    }

}
