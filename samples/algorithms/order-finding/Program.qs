// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.OrderFinding {
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;

    @EntryPoint()
    operation GetOrder(index : Int) : Unit {
        let perm = [1, 2, 3, 0];
        let shots = 1024;

        // print some info on the permutation
        Message($"Permutation: {perm}");
        Message($"Find cycle length at index {index}\n");

        // early exit for index out of bounds 
        if (index < 0 or index >= Length(perm)){
            Message("Index must be value from 0 to 3");
            return ();
        }

        // compute exact order
        Message($"Exact Order: {ComputedOrder(index, perm)}");

        // guess order classically
        Message("\nGuess classically:");
        GuessOrder(index, perm, shots, GuessOrderClassical);

        // guess order quantum computationally
        Message("\nGuess using quantum algorithm");
        GuessOrder(index, perm, shots, GuessOrderQuantum);
    }
    
    /// # Summary
    /// Returns the exact order (length) of the cycle that contains a given index.
    internal function ComputedOrder(index : Int, perm : Int[]) : Int {
        mutable order = 1;
        mutable cur = index;

        while (index != perm[cur]) {
            set order = order + 1;
            set cur = perm[cur];
        }

        return order;
    }

    /// # Summary
    /// Guesses order using Q# for shots times, and returns the percentage for each order that was returned.
    internal operation GuessOrder(index: Int, perm: Int[], shots : Int, guessMode: ((Int, Int[]) => Int)) : Unit {
        mutable counts = [0, 0, 0, 0];

        for (_ in 0 .. shots - 1) {
            let guess = guessMode(index, perm);
            set counts w/= (guess - 1) <- counts[guess - 1] + 1;
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
    internal operation GuessOrderClassical(index : Int, perm : Int[]) : Int {
        let rnd = DrawRandomBool(0.5);
        if (perm[perm[perm[index]]] == index) {
            return rnd ? 1 | 3;
        }
        else {
            return rnd ? 2 | 4;
        }
    }

    /// # Summary
    /// The quantum estimation calls the quantum algorithm in the Q# file which computes the permutation
    /// πⁱ(input) where i is a superposition of all values from 0 to 7.  The algorithm then uses QFT to
    /// find a period in the resulting state.  The result needs to be post-processed to find the estimate.
    internal operation GuessOrderQuantum(index: Int, perm: Int[]) : Int {
        let result = FindOrder(perm, index);

        if (result == 0) {
            let guess = DrawRandomDouble(0.0, 1.0);
            // the probability distribution is extracted from the second
            // column (m = 0) in Fig. 2's table on the right-hand side,
            // in the original and referenced paper.
            if (guess <= 0.5505) {
                return 1;
            } elif (guess <= 0.5505 + 0.1009) {
                return 2;
            } elif (guess <= 0.5505 + 0.1009 + 0.1468) {
                return 3;
            } else {
                return 4;
            }
        } elif (result % 2 == 1) {
            return 3;
        } elif (result == 2 or result == 6) {
            return 4;
        } else {
            return 2;
        }
    }
}
