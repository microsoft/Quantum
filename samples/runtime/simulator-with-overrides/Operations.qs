// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.SimulatorWithOverrides {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Run a series of experiments that on a perfect state simulator produce matching measurement results.
    /// If executed on a simulator which introduces errors in measurements, 
    /// a certain percentage of experiments will produce mismatched results.
    operation DoCorrelatedMeasurements () : Unit {
        let nRuns = 100;
        mutable nSame = 0;
        for _ in 1 .. nRuns {
            use q1 = Qubit();
            use q2 = Qubit();
            // Prepare a Bell pair (in this state the measurement results on two qubits should be the same)
            H(q1);
            CNOT(q1, q2);
        
            // Measure both qubits; if there is an error introduced during one of the measurements (but not both), the results will diverge
            if (M(q1) == M(q2)) {
                set nSame += 1;
            }

            // Make sure to return the qubits to 0 state
            ResetAll([q1, q2]);
        }
        Message($"{nSame} runs out of {nRuns} produced the same results.");
    }
}
