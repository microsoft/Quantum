// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Extensions.Oracles
{
    /// # Summary
    /// Apply a classical permutation oracle to two registers.
    ///
    /// # Description
    /// The effect of the oracle is a permutation of basis states according to
    /// the provided classical function:
    /// $$
    /// \begin{align}
    ///     \ket{x}\ket{y}\ket{w} \rightarrow \ket{x}\ket{f(x, y)}\ket{w},
    /// \end{align}
    /// $$
    /// with registers x, y, w and the oracle function f. 
    ///
    /// # Input
    /// ## oracle
    /// A function that defines the action of the oracle on the computational
    /// basis states of the two registers x, y. The mapping
    /// $$
    /// \begin{align}
    ///		$(x, y) \rightarrow (x, z=f(x, y))$
    /// \end{align}
    /// $$
    /// must be a bijective mapping on the basis states.
    /// ## xbits
    /// Input register x.
    /// ## ybits
    /// Output register y.
    operation PermutationOracle(oracle : ((Int, Int) -> Int), xbits : Qubit[], ybits : Qubit[]) : Unit
    {
        body (...)
        {
            fail "not implemented for general target machines yet";
        }
        adjoint auto;
    }
}
