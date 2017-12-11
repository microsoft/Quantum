// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Represents a discrete-time oracle $U^m$ for a fixed operation $U$
    /// and a non-negative integer $m$.
    newtype DiscreteOracle = ((Int, Qubit[]) => ():Adjoint,Controlled);

    /// # Summary
    /// Represents a continuous-time oracle
    /// $U(\delta t) : \ket{\psi(t)} \mapsto \ket{\psi(t + \delta t)}
    /// for all times $t$, where $U$ is a fixed operation, and where
    /// and $\delta t$ is a non-negative real number.
    newtype ContinuousOracle = ((Double, Qubit[]) => ():Adjoint,Controlled);

    /// # Summary
    /// Given an operation representing a "black-box" oracle, returns a discrete-time oracle 
    /// which represents the "black-box" oracle repeated multiple times.
    ///
    /// # Input
    /// ## blackBoxOracle
    /// The operation to be exponentiated
    ///
    /// # Output
    /// An operation partially applied over the "black-box" oracle representing the discrete-time oracle 
    ///
    /// # Example
    /// `OracleToDiscrete(U)(3, target)` is equivalent to `U(target)` repeated three times.
    operation OracleToDiscrete(blackBoxOracle : (Qubit[] => (): Adjoint, Controlled))  : DiscreteOracle
    {
        body {
            let oracle = DiscreteOracle(OperationPowImplCA(blackBoxOracle, _, _));
            return oracle;
        }
    }

}
