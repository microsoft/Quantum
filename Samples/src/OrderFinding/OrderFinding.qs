// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.OrderFinding {
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Samples.ReversibleLogicSynthesis;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;

    /// # Summary
    /// Given a permutation π, this function returns the
    /// square of π, i.e., the permutation π².
    ///
    /// # Input
    /// ## perm
    /// A permutation with elements 0, ..., n - 1
    ///
    /// # Output
    /// The square of the input permutation
    ///
    /// # Example
    /// ```Q#
    /// Square([1, 2, 3, 0]), // [2, 3, 0, 1]
    /// Square([2, 3, 0, 1]), // [0, 1, 2, 3]
    /// ```
    function Square(perm : Int[]) : Int[] {
        mutable squaredPermutation = new Int[Length(perm)];
        for (i in 0..Length(perm) - 1) {
            set squaredPermutation[i] = perm[perm[i]];
        }
        return squaredPermutation;
    }

    /// # Summary
    /// Implements the Order Finding algorithm as described in L.M.K. Vandersypen et al., PRL 85, 5452, 2000 (https://arxiv.org/abs/quant-ph/0007017).
    ///
    /// The input permutation has 2ⁿ elements.  Then the quantum circuit
    /// has 2n + 1 qubits, where the n + 1 upper qubits are used to create
    /// a superposition over 2ⁿ⁺¹ numbers, which represent the exponents
    /// of the permutation.  The permutation is called n + 1 times for exponents
    /// 2⁰, 2¹, ..., 2ⁿ on the lower n qubits.  For each exponent, we update the
    /// permutation and compute a quantum circuit using reversible logic synthesis
    /// from the namespace `Microsoft.Quantum.Samples.ReversibleLogicSynthesis`.
    /// Finally, a QFT is applied to the upper qubits.
    ///
    /// # Input
    /// ## perm
    /// The input permutation
    ///
    /// ## index
    /// Index of permutation
    ///
    operation OrderFinding(perm : Int[], input : Int) : Int {
        let n = BitSize(Length(perm) - 1);
        mutable accumulatedPermutation = perm;

        using ((topQubits, bottomQubits) = (Qubit[n + 1], Qubit[n])) {
            ApplyToEach(H, topQubits);

            for (i in 0..n) {
                Controlled (PermutationOracle(accumulatedPermutation, TBS, _))([topQubits[n - i]], bottomQubits);
                set accumulatedPermutation = Square(accumulatedPermutation);
            }

            QFT(BigEndian(topQubits));

            let result = MeasureInteger(BigEndianAsLittleEndian(BigEndian(topQubits)));

            ResetAll(topQubits + bottomQubits);

            return result;
        }
    }
}
