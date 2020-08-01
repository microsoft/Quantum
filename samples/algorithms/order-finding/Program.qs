// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.OrderFinding {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;

    @EntryPoint()
    operation GuessOrderQuantum(index : Int) : Unit {
        let perm = [1, 2, 3, 0];

        // print some info on the permutation
        Message($"Permutation: {perm}");
        Message($"Find cycle length at index {index}\n");

        // early exit for index out of bounds 
        if (index >= Length(perm)){
            Message("Index cannot be greater than 3");
            return ();
        }

        // compute exact order
        Message($"Exact Order: {ComputeOrder(index, perm)}\n");

        return ();
    }
    

    /// # Summary
    /// Returns the exact order (length) of the cycle that contains a given index.
    function ComputeOrder(index : Int, perm : Int[]) : Int {
        // ...
        mutable order = 1;
        mutable cur = index;
        while (index != perm[cur]) {
            set order = order + 1;
            set cur = perm[cur];
        }
        return order;
    }
}