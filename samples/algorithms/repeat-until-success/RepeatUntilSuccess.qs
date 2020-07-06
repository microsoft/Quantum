namespace Microsoft.Quantum.Samples.RepeatUntilSuccess {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Preparation;

    /// Example of a Repeat-until-success circuit implementing exp(i⋅ArcTan(2)⋅Z)
    /// by Paetznick & Svore. Gate exp(i⋅ArcTan(2)⋅Z) is also know as V gate.
    /// # References
    /// - [ *Adam Paetznick, Krysta M. Svore*,
    ///     Quantum Information & Computation 14(15 & 16): 1277-1301 (2014)
    ///   ](https://arxiv.org/abs/1311.1074)
    /// For circuit, see file RUS.png (to be added to README).
    ///
    /// The circuit is executed on a "target" qubit using an "ancilla" and 
    /// "resource" qubit. The circuit consists of two parts (red and blue in image).
    /// The goal is to measure Zero for both the ancilla and resource qubit.
    /// If this succeeds, the circuit will have effectively applied an 
    /// Rz(arctan(2)) gate (also known as V_3 gate) on the target qubit.
    /// If this fails, rerun the circuit up to <limit> times.
    @EntryPoint()
    operation ApplyRzArcTan2(
        inputValue : Bool,
        inputBasis: Pauli,
        limit: Int
    ) : (Bool, Result, Int) {
        using ((ancilla, resource, target) = (Qubit(), Qubit(), Qubit())) {
            // Prepare qubits
            PrepareXZero(ancilla);
            PrepareXZero(resource);
            PrepareValueForBasis(inputValue, inputBasis, target);

            // Initialize results to One by default.
            mutable result1 = One;
            mutable result2 = One;
            mutable done = false;
            mutable numIter = 0;

            repeat {
                PrepareXZero(ancilla);
                // Run Part 1 of the circuit.
                set result1 = ApplyAndMeasurePart1(ancilla, resource);
                // We'll only run Part 2 if Part 1 returns Zero.
                // Otherwise, we'll skip and rerun Part 1 again.
                if (result1 == Zero) { //|0X>
                    set result2 = ApplyAndMeasurePart2(resource, target);
                    if (result2 == One) { //|01>
                        H(ancilla); // Reset ancilla from |0> to |+>
                        PrepareXZero(resource); // Reset resource from |1> to |+>
                        Adjoint Z(target); // Correct effective Z rotation on target
                    }
                } else { // |1X>, skip Part 2
                    // Reset ancilla from |1> to |+>
                    PrepareXZero(ancilla);
                }
                set done = (result2 == Zero or numIter >= limit); //|00>
                set numIter = numIter + 1;
            }
            until (done)
            fixup {}

            let success = (result1 == Zero and result2 == Zero);

            // Rz(2.0*ArcTan(2.0), target);
            let result = Measure([inputBasis], [target]);

            Reset(target);
            Reset(resource);
            Reset(ancilla);

            return ( success, result, numIter );
        }
    }

    // Prepare qubit in either |0> or |1> for the given basis
    operation PrepareValueForBasis(
        inputValue : Bool,
        inputBasis : Pauli,
        input: Qubit) : Unit {
            if (inputValue) {
                X(input);
            }
            PrepareQubit(inputBasis, input);
    }

    // Prepare qubit in |+> state given it is in the |1> state
    operation PrepareXZero(target : Qubit) : Unit {
        X(target); // Flip to |0>
        H(target); // Prepare |+>
    }

    // Part 1 of RUS circuit (red)
    operation ApplyAndMeasurePart1(
        ancilla: Qubit,
        resource: Qubit
    ) : Result {
        within {
            Adjoint T(ancilla);
        } apply {
            CNOT(resource, ancilla);
        }

        return Measure([PauliX], [ancilla]);
    }

    // Part 2 of RUS circuit (blue)
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
