// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.RepeatUntilSuccess {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Preparation;

    /// # Summary
    /// Example of a Repeat-until-success algorithm implementing a circuit 
    /// that achieves exp(i⋅ArcTan(2)⋅Z) by Paetznick & Svore. 
    /// Gate exp(i⋅ArcTan(2)⋅Z) is also know as V gate.
    /// # References
    /// - [ *Adam Paetznick, Krysta M. Svore*,
    ///     Quantum Information & Computation 14(15 & 16): 1277-1301 (2014)
    ///   ](https://arxiv.org/abs/1311.1074)
    /// For circuit diagram, see file RUS.png (to be added to README).
    ///
    /// The program executes a circuit on a "target" qubit using an "auxiliary" and 
    /// "resource" qubit. The circuit consists of two parts (red and blue in image).
    /// The goal is to measure Zero for both the auxiliary and resource qubit.
    /// If this succeeds, the program will have effectively applied an 
    /// Rz(arctan(2)) gate (also known as V_3 gate) on the target qubit.
    /// If this fails, the program reruns the circuit up to <limit> times.
    @EntryPoint()
    operation ApplyRzArcTan2(
        inputValue : Bool,
        inputBasis: Pauli,
        limit: Int
    ) : (Bool, Result, Int) {
        using ((auxiliary, resource, target) = (Qubit(), Qubit(), Qubit())) {
            /// Prepare auxiliary and resource qubits in |+> state
            SetXZeroFromOne(auxiliary);
            SetXZeroFromOne(resource);
            /// Prepare target qubit in |0> or |1> state, depending on input value
            PrepareValueForBasis(inputValue, inputBasis, target);

            /// Initialize results to One by default.
            mutable done = false;
            mutable success = false;
            mutable numIter = 0;

            repeat {
                SetXZeroFromOne(auxiliary);
                // Run Part 1 of the program.
                let result1 = ApplyAndMeasurePart1(auxiliary, resource);
                // We'll only run Part 2 if Part 1 returns Zero.
                // Otherwise, we'll skip and rerun Part 1 again.
                if (result1 == Zero) { //|0X>
                    let result2 = ApplyAndMeasurePart2(resource, target);
                    if (result2 == Zero) { //|00>
                        set success = true;
                    } else { //|01>
                        H(auxiliary); // Reset auxiliary from |0> to |+>
                        SetXZeroFromOne(resource); // Reset resource from |1> to |+>
                        Adjoint Z(target); // Correct effective Z rotation on target
                    }
                } else { // |1X>, skip Part 2
                    // Reset auxiliary from |1> to |+>
                    SetXZeroFromOne(auxiliary);
                }
                set done = (success or numIter >= limit);
                set numIter = numIter + 1;
            }
            until (done);

            let result = Measure([inputBasis], [target]);
            return ( success, result, numIter );
        }
    }

    /// Prepare qubit in either |0> or |1> for the given basis
    operation PrepareValueForBasis(
        inputValue : Bool,
        inputBasis : Pauli,
        input: Qubit
        ) : Unit {
            if (inputValue) {
                X(input);
            }
            PrepareQubit(inputBasis, input);
    }

    /// Prepare qubit in |+> state given it is in the |1> state
    operation SetXZeroFromOne(target : Qubit) : Unit {
        X(target); // Flip to |0>
        H(target); // Prepare |+>
    }

    /// Part 1 of RUS circuit (red)
    operation ApplyAndMeasurePart1(
        auxiliary: Qubit,
        resource: Qubit
    ) : Result {
        within {
            Adjoint T(auxiliary);
        } apply {
            CNOT(resource, auxiliary);
        }

        return Measure([PauliX], [auxiliary]);
    }

    /// Part 2 of RUS circuit (blue)
    operation ApplyAndMeasurePart2(
        resource: Qubit,
        target: Qubit
    ) : Result {
        CNOT(target, resource);
        T(resource);
        T(target);
        
        return Measure([PauliX], [resource]);
    }
}
