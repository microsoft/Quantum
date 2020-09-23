// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.RepeatUntilSuccess {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;

    /// # Summary
    /// Example of a Repeat-until-success algorithm implementing a circuit 
    /// that achieves (I + i√2X)/√3 by Paetznick & Svore. This is the smallest
    /// circuit found in the referenced work and described in figure 8.
    /// # References
    /// - [ *Adam Paetznick, Krysta M. Svore*,
    ///     Quantum Information & Computation 14(15 & 16): 1277-1301 (2014)
    ///   ](https://arxiv.org/abs/1311.1074)
    /// For circuit diagram, see file SimpleRUS.png.
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
    /// qubit.
    /// The goal is to measure Zero for the auxiliary qubit.
    /// If this succeeds, the program will have effectively applied an 
    /// (I + i√2X)/√3 gate on the target qubit.
    /// If this fails, the program reruns the circuit up to <limit> times.
    operation CreateQubitsAndApplySimpleGate(
        inputValue : Bool,
        inputBasis : Pauli,
        limit : Int
    )
    : ( Bool, Result, Int ) {
        using (register = Qubit[2]) {
            let (success, numIter) = ApplySimpleGate(
                inputBasis, inputValue, limit, register);
            let result = Measure([inputBasis], [register[1]]);
            return (success, result, numIter);
        }
    }

    /// # Summary
    /// Apply (I + i√2X)/√3 on qubits using repeat until success algorithm.
    ///
    /// # Input
    /// ## inputBasis
    /// Pauli basis in which to prepare input qubit
    /// ## inputValue
    /// Boolean value for input qubit (true maps to One, false maps to Zero)
    /// ## limit
    /// Integer limit to number of repeats of circuit
    /// ## register
    /// Qubit register including auxiliary and target qubits
    ///
    /// # Output
    /// Tuple of (success, numIter) where success = false if the number of 
    /// iterations (numIter) exceeds the input <limit>
    operation ApplySimpleGate(
        inputBasis : Pauli,
        inputValue : Bool,
        limit : Int,
        register : Qubit[]
    )
    : (Bool, Int) {
        // Initialize results to One by default.
        mutable done = false;
        mutable success = false;
        mutable numIter = 0;
        // Prepare target qubit in |0⟩ or |1⟩ state, depending on input value
        if (inputValue) {
            X(register[1]);
        }
        PrepareQubit(inputBasis, register[1]);

        repeat {
            // Assert valid starting states for all qubits
            AssertMeasurement([PauliZ], [register[0]], Zero,
             "Auxiliary qubit is not in |0⟩ state.");
            AssertQubitIsInState(register[1], inputBasis, inputValue);
            ApplySimpleRUSCircuit(register);
            set success = MResetZ(register[0]) == Zero;
            set done = success or (numIter >= limit);
            set numIter = numIter + 1;
        }
        until (done);
        return (success, numIter);
    }

    /// # Summary
    /// Apply RUS circuit on qubit register
    ///
    /// # Input
    /// ## register
    /// Qubit register including auxiliary and target qubits
    operation ApplySimpleRUSCircuit(
        register : Qubit[]
    )
     : Unit {
        H(register[0]);
        T(register[0]);
        CNOT(register[0], register[1]);
        H(register[0]);
        CNOT(register[0], register[1]);
        T(register[0]);
        H(register[0]);
    }
}
