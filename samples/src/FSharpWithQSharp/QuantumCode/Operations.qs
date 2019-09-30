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
    /// A bit vector of length N represented as Int[]
    /// ## x
    /// N qubits in arbitrary state |x⟩ (input register)
    /// ## y
    /// A qubit in arbitrary state |y⟩ (output qubit)
    operation ApplyProductWithNegationFunction (r : Int[], x : Qubit[], y : Qubit) : Unit is Adj {
        for (idx in IndexRange(x)) {
            if (r[idx] == 1) {
                CNOT(x[idx], y);
            } else {
                // do a 0-controlled NOT
                (ControlledOnInt(0, X))([x[idx]], y);
            }
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
    operation RestoreOracleParameters(N : Int, oracle : ((Qubit[], Qubit) => Unit)) : Int[] {
        using ((x, y) = (Qubit[N], Qubit())) {
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
                   ? ConstantArray(N, 0) w/ 0 <- 1
                   | ConstantArray(N, 0);
        }
    }

    /// # Summary
    /// Instantiates the oracle and runs the parameter restoration algorithm.
    operation RunAlgorithm(bits : Int[]) : Int[] {
        Message("Hello, quantum world!");
        // construct an oracle using the input array
        let oracle = ApplyProductWithNegationFunction(bits, _, _);
        // run the algorithm on this oracle and return the result
        return RestoreOracleParameters(Length(bits), oracle);
    }
}
