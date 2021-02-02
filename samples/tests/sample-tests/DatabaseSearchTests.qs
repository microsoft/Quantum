// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Samples.DatabaseSearch;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;

    /// # Summary
    /// Performs quantum search for the marked element and checks whether
    /// the success probability matches theoretical predictions. Then checks
    /// whether the correct index is found, post-selected on success.
    @Test("QuantumSimulator")
    operation TestGroverSearch() : Unit {
        for nDatabaseQubits in 4 .. 6 {
            for nIterations in 0 .. 5 {
                use markedQubit = Qubit();
                use databaseRegister = Qubit[nDatabaseQubits];

                // Choose marked elements to be 1, 4, and 9.
                let markedElements = [1, 4, 9];
                let nMarkedElements = Length(markedElements);
                GroverSearch(markedElements, nIterations, 0)([markedQubit] + databaseRegister);

                // Theoretical success probability.
                let successAmplitude = Sin(IntAsDouble(2 * nIterations + 1) * ArcSin(Sqrt(IntAsDouble(nMarkedElements) / IntAsDouble(2 ^ nDatabaseQubits))));
                let successProbability = successAmplitude * successAmplitude;
                AssertMeasurementProbability([PauliZ], [markedQubit], One, successProbability, "Error: Success probability does not match theory", 1E-10);

                let result = MResetZ(markedQubit);
                let number = ResultArrayAsInt(ForEach(MResetZ, databaseRegister));

                if (result == One) {
                    if (not Any(EqualI(number, _), markedElements)) {
                        fail "Found index should be in MarkedElements.";
                    }
                }
            }
        }
    }

}
