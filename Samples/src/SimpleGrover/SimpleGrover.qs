// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.SimpleGrover {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
	open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
	open Microsoft.Quantum.Arithmetic;

    // This operation adds a (-1)-phase to the marked state(s)
    operation ReflectMarked (inputQubits : Qubit[]) : Unit is Adj + Ctl {
        using (outputQubit = Qubit()) {
            within {
                // Initialize the outputQubit to 1/sqrt(2) ( |0> - |1> )
                // so that toggling it results in a (-1)-phase
                X(outputQubit);
                H(outputQubit);
            }
            apply {
                // Flip the outputQubit for marked states.
                // Here: For the state with alternating 0s and 1s
                within {
                    ApplyToEachCA(X, inputQubits[0..2..Length(inputQubits)-1]);
                }
                apply {
                    (Controlled X) (inputQubits, outputQubit);
                }
            }
        }
    }
    
    // This operation adds a (-1)-phase to the uniform superposition
    operation ReflectUniform (inputQubits : Qubit[]) : Unit is Adj + Ctl {    
        within {
            // Transform the uniform superposition to all-zero
            ApplyToEachCA(H, inputQubits);
            // Transform the all-zero state to all-ones
            ApplyToEachCA(X, inputQubits);
        }
        apply {
            // Add a (-1)-phase to the all-ones state
            (Controlled Z) (Rest(inputQubits), Head(inputQubits));
        }
    }
    
    // This operation applies Grover search using `numQubits` qubits
    // to represent the index / input to the function.
    operation ApplyGrover (numQubits : Int) : Bool[] {
        let N = 1 <<< numQubits; // 2^numQubits
        // compute number of iterations:
        let angle = ArcSin(1. / Sqrt(IntAsDouble(N)));
        let numIterations = Round(0.25 * PI() / angle - 0.5);

        // Apply Grover search
        using (qubits = Qubit[numQubits]) {
            // initialize uniform superposition
            ApplyToEach(H, qubits);
            // perform iterations
            for (i in 0..numIterations-1) {
                ReflectMarked(qubits);
                ReflectUniform(qubits);
            }
            // measure the answer
            let measuredInt = MeasureInteger(LittleEndian(qubits));
            return IntAsBoolArray(measuredInt, numQubits);
        }
    }
}