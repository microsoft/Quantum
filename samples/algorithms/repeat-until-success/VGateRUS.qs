// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.RepeatUntilSuccess {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Example of a Repeat-until-success algorithm implementing a circuit 
    /// that achieves exp(i⋅ArcTan(2)⋅Z) by Paetznick & Svore. 
    /// The exp(𝑖 ArcTan(2) 𝑍) operation is also known as the "𝑉 gate."
    /// # References
    /// - [ *Adam Paetznick, Krysta M. Svore*,
    ///     Quantum Information & Computation 14(15 & 16): 1277-1301 (2014)
    ///   ](https://arxiv.org/abs/1311.1074)
    /// For circuit diagram, see file RUS.png.
    ///
    /// # Input
    /// ## inputBasis
    /// Pauli basis in which to prepare input qubit
    /// ## inputValue
    /// Boolean value for input qubit (true maps to One, false maps to Zero)
    /// ## limit
    /// Integer limit to number of repeats of circuit
    ///
    /// # Remarks
    /// The program executes a circuit on a "target" qubit using an "auxiliary"
    /// and "resource" qubit. The circuit consists of two parts (red and blue 
    /// in image).
    /// The goal is to measure Zero for both the auxiliary and resource qubit.
    /// If this succeeds, the program will have effectively applied an 
    /// Rz(arctan(2)) gate (also known as V_3 gate) on the target qubit.
    /// If this fails, the program reruns the circuit up to <limit> times.
    operation CreateQubitsAndApplyRzArcTan2(
        inputValue : Bool,
        inputBasis : Pauli,
        limit : Int
    )
    : (Bool, Result, Int) {
        using ((auxiliary, resource, target) = (Qubit(), Qubit(), Qubit())) {
            // Initialize qubits to starting values (|+⟩, |+⟩, |0⟩/|1⟩)
            InitializeQubits(
                inputBasis, inputValue, auxiliary, resource, target
                );
            let (success, numIter) = ApplyRzArcTan2(
                inputBasis, inputValue, limit, auxiliary, resource, target);
            let result = Measure([inputBasis], [target]);
            // From version 0.12 it is no longer necessary to release qubits 
            /// in zero state.
            ResetAll([target, resource, auxiliary]);
            return (success, result, numIter);
        }
    }

    /// # Summary
    /// Apply Rz(arctan(2)) on qubits using repeat until success algorithm.
    ///
    /// # Input
    /// ## inputBasis
    /// Pauli basis in which to prepare input qubit
    /// ## inputValue
    /// Boolean value for input qubit (true maps to One, false maps to Zero)
    /// ## limit
    /// Integer limit to number of repeats of circuit
    /// ## auxiliary
    /// Auxiliary qubit
    /// ## resource
    /// Resource qubit
    /// ## target
    /// Target qubit
    ///
    /// # Output
    /// Tuple of (success, numIter) where success = false if the number of 
    /// iterations (numIter) exceeds the input <limit>
    operation ApplyRzArcTan2(
        inputBasis : Pauli,
        inputValue : Bool,
        limit : Int,
        auxiliary : Qubit,
        resource : Qubit,
        target : Qubit
    )
    : (Bool, Int) {
        // Initialize results to One by default.
        mutable done = false;
        mutable success = false;
        mutable numIter = 0;

        repeat {
            // Assert valid starting states for all qubits
            AssertMeasurement([PauliX], [auxiliary], Zero,
             "Auxiliary qubit is not in |+⟩ state.");
            AssertMeasurement([PauliX], [resource], Zero,
             "Resource qubit is not in |+⟩ state.");
            AssertQubitIsInState(target, inputBasis, inputValue);

            // Run Part 1 of the program.
            let result1 = ApplyAndMeasurePart1(auxiliary, resource);
            // We'll only run Part 2 if Part 1 returns Zero.
            // Otherwise, we'll skip and rerun Part 1 again.
            if (result1 == Zero) { //|0+⟩
                let result2 = ApplyAndMeasurePart2(resource, target);
                if (result2 == Zero) { //|00⟩
                    set success = true;
                } else { //|01⟩
                    Z(resource); // Reset resource from |-⟩ to |+⟩
                    Adjoint Z(target); // Correct effective Z rotation on target
                }
            } else { //|1+⟩
                // Set auxiliary and resource qubit back to |+⟩
                Z(auxiliary);
                Reset(resource);
                H(resource);
            }
            set done = success or (numIter >= limit);
            set numIter = numIter + 1;
        }
        until (done);
        return (success, numIter);
    }

    /// # Summary
    /// Initialize axiliary and resource qubits in |+⟩, target in |0⟩ or |1⟩.
    ///
    /// # Input
    /// ## inputBasis
    /// Pauli basis in which to prepare input qubit
    /// ## inputValue
    /// Boolean value for input qubit (true maps to One, false maps to Zero)
    /// ## limit
    /// Integer limit to number of repeats of circuit
    /// ## auxiliary
    /// Auxiliary qubit
    /// ## resource
    /// Resource qubit
    /// ## target
    /// Target qubit
    operation InitializeQubits(
        inputBasis : Pauli,
        inputValue : Bool,
        auxiliary : Qubit,
        resource : Qubit,
        target : Qubit
    )
     : Unit {
        // Prepare auxiliary and resource qubits in |+⟩ state
        H(auxiliary);
        H(resource);

        // Prepare target qubit in |0⟩ or |1⟩ state, depending on input value
        if (inputValue) {
            X(target);
        }
        PrepareQubit(inputBasis, target);
    }

    /// # Summary
    /// Apply part 1 of RUS circuit (red circuit shown in README) and measure 
    /// auxiliary qubit in Pauli X basis 
    ///
    /// # Input
    /// ## auxiliary
    /// Auxiliary qubit
    /// ## resource
    /// Resource qubit
    operation ApplyAndMeasurePart1(
        auxiliary : Qubit,
        resource : Qubit
    )
     : Result {
        within {
            T(auxiliary);
        } apply {
            CNOT(resource, auxiliary);
        }

        return Measure([PauliX], [auxiliary]);
    }

    /// # Summary
    /// Apply part 2 of RUS circuit (blue circuit shown in README) and measure 
    /// resource qubit in Pauli X basis
    ///
    /// # Input
    /// ## resource
    /// Resource qubit
    /// ## target
    /// Target qubit
    operation ApplyAndMeasurePart2(resource : Qubit, target : Qubit)  : Result {
        T(target);
        Z(target);
        CNOT(target, resource);
        T(resource);
        
        return Measure([PauliX], [resource]);
    }

    /// # Summary
    /// Assert target qubit state is the desired input value in the desired 
    /// input basis.
    ///
    /// ## target
    /// Target qubit
    /// ## inputBasis
    /// Pauli basis in which to prepare input qubit
    /// ## inputValue
    /// Boolean value for input qubit (true maps to One, false maps to Zero)
    operation AssertQubitIsInState(
        target : Qubit,
        inputBasis : Pauli,
        inputValue : Bool
    )
     : Unit {
        AssertMeasurement(
            [inputBasis], [target], inputValue ? One | Zero,
            $"Qubit is not in {inputValue ? One | Zero} state for given input basis."
        );
    }
}
