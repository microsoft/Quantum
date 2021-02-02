﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;

    /// # Summary
    /// A quantum oracle which implements the following function:
    /// f(x₀, …, xₙ₋₁) = Σᵢ (rᵢ xᵢ + (1 - rᵢ)(1 - xᵢ)) modulo 2 for a given bit vector r = (r₀, …, rₙ₋₁).
    ///
    /// # Input
    /// ## r
    /// A bit vector of length N
    /// ## x
    /// N qubits in arbitrary state |x⟩ (input register)
    /// ## y
    /// A qubit in arbitrary state |y⟩ (output qubit)
    operation ApplyProductWithNegationFunction (vector : Bool[], controls : Qubit[], target : Qubit)
    : Unit is Adj {
        for (bit, control) in Zipped(vector, controls) {
            ControlledOnInt(bit ? 1 | 0, X)([control], target);
        }
    }

    /// # Summary
    /// Reconstructs the parameters of the oracle in a single query
    ///
    /// # Input
    /// ## N
    /// The number of qubits in the input register N for the function f
    /// ## oracle
    /// A quantum operation which implements the oracle |x⟩|y⟩ -> |x⟩|y ⊕ f(x)⟩, where
    /// x is an N-qubit input register, y is a 1-qubit answer register, and f is a Boolean function.
    /// The function f implemented by the oracle can be represented as
    /// f(x₀, …, xₙ₋₁) = Σᵢ (rᵢ xᵢ + (1 - rᵢ)(1 - xᵢ)) modulo 2 for some bit vector r = (r₀, …, rₙ₋₁).
    ///
    /// # Output
    /// A bit vector r which generates the same oracle as the given one
    /// Note that this doesn't have to be the same bit vector as the one used to initialize the oracle!
    operation ReconstructOracleParameters(N : Int, oracle : ((Qubit[], Qubit) => Unit)) : Bool[] {
        use x = Qubit[N];
        use y = Qubit();

        // apply oracle to qubits in all 0 state
        oracle(x, y);

        // f(x) = Σᵢ (rᵢ xᵢ + (1 - rᵢ)(1 - xᵢ)) = 2 Σᵢ rᵢ xᵢ + Σᵢ rᵢ + Σᵢ xᵢ + N = Σᵢ rᵢ + N
        // remove the N from the expression
        if (N % 2 == 1) {
            X(y);
        }

        // now y = Σᵢ rᵢ

        // measure the output register
        let m = MResetZ(y);

        // before releasing the qubits make sure they are all in |0⟩ state
        ResetAll(x);
        return m == One
                ? ConstantArray(N, false) w/ 0 <- true
                | ConstantArray(N, false);
    }

    /// # Summary
    /// Instantiates the oracle and runs the parameter restoration algorithm.
    operation RunAlgorithm(bits : Bool[]) : Bool[] {
        Message("Hello, quantum world!");
        // construct an oracle using the input array
        let oracle = ApplyProductWithNegationFunction(bits, _, _);
        // run the algorithm on this oracle and return the result
        return ReconstructOracleParameters(Length(bits), oracle);
    }
}
