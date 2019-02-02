// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.UnitTesting {
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Superdense coding unit tests
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    /// # Summary
    /// Tests SuperdenseCodingProtocolRun on all possible inputs.
    operation SuperdenseCodingTest () : Unit {
        
        // Calls SuperdenseCodingProtocolRun 4 times with
        // arguments [a,b] where a tuple of integers (a,b) belongs to
        // the Cartesian square {0,1}².
        IterateThroughCartesianPower(2, 2, SuperdenseCodingProtocolRun);
    }
    
}


