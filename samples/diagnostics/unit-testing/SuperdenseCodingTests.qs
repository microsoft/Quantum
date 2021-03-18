// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Superdense coding unit tests
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// Tests SuperdenseCodingProtocolRun on all possible inputs.
    @Test("QuantumSimulator")
    operation CheckSuperdenseCodingWorks() : Unit {
        // Calls SuperdenseCodingProtocolRun 4 times with
        // arguments [a,b] where a tuple of integers (a,b) belongs to
        // the Cartesian square {0,1}².
        IterateThroughCartesianPower(2, 2, RunSuperdenseCoding);
    }

}
