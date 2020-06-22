// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.ReversibleLogicSynthesis {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation RunProgram() : Unit {
        let perm = [0, 2, 3, 5, 7, 1, 4, 6];
        let res = SimulatePermutation(perm);
        Message($"Does circuit realize permutation: {res}");

        for (shift in IndexRange(perm)) {
            let measuredShift = FindHiddenShift(perm, shift);
            Message($"Applied shift = {shift}   Measured shift: {measuredShift}");
        }
    }
}
