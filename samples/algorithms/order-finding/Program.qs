// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.OrderFinding {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;

    @EntryPoint()
    operation GuessOrder(index : Int) : Unit {
        let perm = [1, 2, 3, 0];
        let shots = 1024;

        // print some info on the permutation
        Message($"Permutation: {perm}");
        Message($"Find cycle length at index {index}\n");

        // early exit for index out of bounds 
        if (index >= Length(perm)){
            Message("Index cannot be greater than 3");
            return ();
        }

        // compute exact order
        Message($"Exact Order: {ComputeOrder(index, perm)}");

        // guess order classically
        Message("\nGuess classically:");
        GuessOrderClassical(index, perm, shots);
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

    /// # Summary
    /// Guesses the order classically by applying estimate `shots` many times and returning the percentage for each order that was returned.
    operation GuessOrderClassical(index : Int, perm : Int[], shots : Int) : Unit {
        mutable guess = 0;
        mutable counts = [0, 0, 0, 0];

        for (_ in 0 .. shots - 1) {
            set guess = GuessOrderClassicalOne(index, perm);
            set counts w/= guess -1 <- counts[guess - 1] + 1;
        }

        for ((i, count) in Enumerated(counts)) {
            if (count > 0) {
                Message($"{i+1}: {IntAsDouble(count) / IntAsDouble(shots) * 100.}%");
            }
        }
    }

    /// # Summary
    /// Guesses the order (classically) for cycle that contains a given index
    ///
    /// The algorithm computes π³(index).  If the result is index, it
    /// returns 1 or 3 with probability 50% each, otherwise, it
    /// returns 2 or 4 with probability 50% each.
    operation GuessOrderClassicalOne(index : Int, perm : Int[]) : Int {
        let rnd = Random([0.5, 0.5]);
        if (perm[perm[perm[index]]] == index) {
            return rnd == 0 ? 1 | 3;
        }
        else {
            return rnd == 0 ? 2 | 4;
        }
    }
}