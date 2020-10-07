// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Samples.PhaseEstimation;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;

    @Test("QuantumSimulator")
    operation BayesianPEIsCorrect() : Unit {
        let expected = 0.571;
        let oracle = EvolveForTime(expected, _, _);

        using (eigenstate = Qubit()) {
            X(eigenstate);
            let actual = EstimatePhase(20001, 60, oracle, [eigenstate]);
            // Give a very generous tolerance to reduce false positive rate.
            EqualityWithinToleranceFact(expected, actual, 0.05);
            Reset(eigenstate);
        }
    }

}
