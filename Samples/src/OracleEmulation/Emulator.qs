// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Extensions.Emulation
{
    /// # Summary
    /// Emulate the effect of a classical oracle by permuting the basis states of the simulator's
    /// wavefunction such that
    ///     $\ket{x}\ket{y}\ket{w} -> \ket{x}\ket{f(x, y)}\ket{w}$,
    /// with registers x, y, w and the oracle function f. 
    ///
    /// # Input
    /// ## oracle
    /// A function that defines the action of the oracle on the computational
    /// basis states of the two registers x, y. The mapping
    ///		$(x, y) \rightarrow (x, z=f(x, y))$
    /// must be a bijective mapping on the basis states.
    /// ## xbits
    /// Input register x.
    /// ## ybits
    /// Output register y.
    operation EmulateOracle(oracle : ((Int, Int) -> Int), xbits : Qubit[], ybits : Qubit[]) : Unit
    {
        body intrinsic;
        adjoint intrinsic;
    }
}
