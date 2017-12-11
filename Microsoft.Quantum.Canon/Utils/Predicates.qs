// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    /// # Summary
    /// The `IsResultZero` function tests if a given Result value is equal to `Zero`.     
    ///
    /// # Input
    /// ## input
    /// `Result` value to be tested.
    /// # Output
    /// Returns `true` if `input` is equal to `Zero`.
    function IsResultZero (input : Result) : Bool {
        return (input == Zero);
    }

    /// # Summary
    /// The `IsResultOne` function tests if a given Result value is equal to `One`.
    ///
    /// # Input
    /// ## input
    /// `Result` value to be tested.
    /// # Output
    /// Returns `true` if `input` is equal to `One`.
    function IsResultOne (input : Result) : Bool {
        return (input == One);
    }
    
}
