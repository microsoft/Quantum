namespace QuantumCode
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    // The oracle: f(x₀, …, xₙ₋₁) = Σᵢ (rᵢ xᵢ + (1 - rᵢ)(1 - xᵢ)) modulo 2 for a given bit vector r = (r₀, …, rₙ₋₁).
    // Inputs:
    //      1) N qubits in arbitrary state |x⟩ (input register)
    //      2) a qubit in arbitrary state |y⟩ (output qubit)
    //      3) a bit vector of length N represented as Int[]
    // The qubit array and the bit vector have the same length.
    operation Oracle_ProductWithNegationFunction (x : Qubit[], y : Qubit, r : Int[]) : Unit {
        
        body (...) {
            for (i in 0 .. Length(x) - 1) {
                if (r[i] == 1) {
                    CNOT(x[i], y);
                } else {
                    // do a 0-controlled NOT
                    X(x[i]);
                    CNOT(x[i], y);
                    X(x[i]);
                }
            }
        }
        
        adjoint invert;
    }

    // The algorithm: reconstruct the oracle in a single query
    // Inputs:
    //      1) the number of qubits in the input register N for the function f
    //      2) a quantum operation which implements the oracle |x⟩|y⟩ -> |x⟩|y ⊕ f(x)⟩, where
    //         x is N-qubit input register, y is 1-qubit answer register, and f is a Boolean function
    //         The function f implemented by the oracle can be represented as
    //         f(x₀, …, xₙ₋₁) = Σᵢ (rᵢ xᵢ + (1 - rᵢ)(1 - xᵢ)) modulo 2 for some bit vector r = (r₀, …, rₙ₋₁).
    // Output:
    //      A bit vector r which generates the same oracle as the given one
    //      Note that this doesn't necessarily mean the same bit vector as the one used to initialize the oracle!
    operation Noname_Algorithm (N : Int, oracle : ((Qubit[], Qubit) => Unit)) : Int[] {
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

    operation RunAlgorithm (bits : Int[]) : Int[] {
        Message("Hello Quantum World!");
        // construct an oracle using the input array
        let oracle = Oracle_ProductWithNegationFunction(_, _, bits);
        // run the algorithm on this oracle and return the result
        return Noname_Algorithm(Length(bits), oracle);
    }
}
