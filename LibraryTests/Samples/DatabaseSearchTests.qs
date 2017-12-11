// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Primitive;

    open Microsoft.Quantum.Samples.DatabaseSearch;

    /// # Summary
    /// Performs quantum search for the marked element and checks whether
    /// the success probability matches theoretical predictions. Then checks
    /// whether the correct index is found, post-selected on success.
    operation GroverTest() : () {
        body {

            for (nDatabaseQubits in 4..6) {
                for (nIterations in 0..5) {
                    using(qubits = Qubit[nDatabaseQubits + 1] ){
                        ResetAll(qubits);

                        let markedQubit = qubits[0];
                        let databaseRegister = qubits[1..nDatabaseQubits];

                        // Choose marked elements to be 1, 4, and 9.
                        let markedElements = [1; 4; 9];
                        let nMarkedElements = Length(markedElements);

                        (GroverSearch( markedElements, nIterations, 0 ))( qubits);

                        // Theoretical success probability.
                        let successAmplitude = Sin( ToDouble(2*nIterations + 1) * ArcSin( Sqrt(ToDouble(nMarkedElements) / ToDouble(2^nDatabaseQubits))  ));
                        let successProbability = successAmplitude * successAmplitude;

                        AssertProb([PauliZ], [markedQubit], One, successProbability, "Error: Success probability does not match theory", 1e-10);

                        let result = M(markedQubit);
                        if (result == One) {
                            let results = MultiM(databaseRegister);
                            let number = PositiveIntFromResultArr(results);
                            mutable elementFound = false;

                            // Verify that found index is in markedElements.
                            for (idxElement in 0..nMarkedElements-1) {
                                if (markedElements[idxElement] == number){
                                    set elementFound = true;
                                }
                            }
                            if (!elementFound) {
                                fail "Found index should be in MarkedElements.";
                            }
                        }

                        ResetAll(qubits);
                    }
                }
            }
        }
    }
}
