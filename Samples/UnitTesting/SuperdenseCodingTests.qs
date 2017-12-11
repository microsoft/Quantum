// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Superdense coding unit tests
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary 
    /// Tests SuperdenseCodingProtocolRun on all possible inputs.
    operation SuperdenseCodingTest () : () {
        body {

            // Calls SuperdenseCodingProtocolRun 4 times with 
            // arguments [a;b] where a tuple of integers (a,b) belongs to 
            // the Cartesian square {0,1}².
            IterateThroughCartesianPower(2,2,SuperdenseCodingProtocolRun);
        }
    }

}
