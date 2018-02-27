// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


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
