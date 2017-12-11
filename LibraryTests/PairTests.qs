// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Canon;

    function PairTest() : () {
        let pair = (12, PauliZ);
        if (Fst(pair) != 12) {
            let actual = Fst(pair);
            fail $"Expected 12, actual {actual}.";
        }
        if (Snd(pair) != PauliZ) {
            let actual = Snd(pair);
            fail $"Expected PauliZ, actual {actual}.";
        }
    }
}
