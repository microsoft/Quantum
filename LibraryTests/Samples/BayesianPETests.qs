// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Samples.PhaseEstimation;
    open Microsoft.Quantum.Canon;

    operation BayesianPEManualTest () : () {
        body {
            let expected = 0.571;
            let actual = BayesianPhaseEstimationSample(expected);
            // Give a very generous tolerance to reduce false positive rate.
            AssertAlmostEqualTol(expected, actual, 0.05);
        }
    }

    operation BayesianPERandomWalkTest () : () {
        body {
            let expected = 0.571;
            let actual = BayesianPhaseEstimationCanonSample(expected);
            // Give a very generous tolerance to reduce false positive rate.
            AssertAlmostEqualTol(expected, actual, 0.05);
        }
    }
}
