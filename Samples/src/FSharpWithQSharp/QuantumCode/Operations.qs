namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

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
    operation ApplyProductWithNegationFunction (r : Int[], x : Qubit[], y : Qubit) : Unit {
        
        body (...) {
            for (i in 0 .. Length(x) - 1) {
                if (r[i] == 1) {
                    CNOT(x[i], y);
                } else {
                    // do a 0-controlled NOT
                    (ControlledOnInt(0, X))([x[i]], y);
                }
            }
        }
        
        adjoint auto;
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
    operation RestoreOracleParameters (N : Int, oracle : ((Qubit[], Qubit) => Unit)) : Int[] {
        mutable r = new Int[N];
        
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
            let m = M(y);
            if (m == One) {
                // adjust parity of bit vector r
                set r[0] = 1;
            }
            
            // before releasing the qubits make sure they are all in |0⟩ state
            ResetAll(x);
            Reset(y);
        }
        
        return r;
    }

    /// # Summary
    /// Instantiates the oracle and runs the parameter restoration algorithm.
    operation RunAlgorithm (bits : Int[]) : Int[] {
        Message("Hello Quantum World!");
        // construct an oracle using the input array
        let oracle = ApplyProductWithNegationFunction(bits, _, _);
        // run the algorithm on this oracle and return the result
        return RestoreOracleParameters(Length(bits), oracle);
    }
}
