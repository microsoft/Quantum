// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Samples.RepeatUntilSuccess;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Math;

    @Test("QuantumSimulator")
    operation TestRepeatUntilSuccessInitialize() : Unit {
        let inputBasis = PauliX;
        let inputValue = true;
        using ((auxiliary, resource, target) = (Qubit(), Qubit(), Qubit())) {
            // Initialize qubits to starting values (|+⟩, |+⟩, |0⟩/|1⟩)
            InitializeQubits(inputBasis, inputValue, auxiliary, resource, target);

            // Assert valid starting states for all qubits
            AssertMeasurement([PauliX], [auxiliary], Zero, "Auxiliary qubit is not in |+⟩ state.");
            AssertMeasurement([PauliX], [resource], Zero, "Resource qubit is not in |+⟩ state.");
            AssertQubitIsInState(target, inputBasis, inputValue);

            // Since the qubits used in this test aren't measured but
            // rather are asserted, we need to reset them manually.
            ResetAll([auxiliary, resource, target]);
        }
    }

    @Test("QuantumSimulator")
    operation TestRepeatUntilSuccessRzArcTan2() : Unit {
        let inputBasis = PauliX;
        let inputValue = true;
        let limit = 50; // typically executes succesfully in n < 10 so 50 is playing it safe 
        using ((auxiliary, resource, target) = (Qubit(), Qubit(), Qubit())) {
            // Initialize qubits to starting values (|+⟩, |+⟩, |0⟩/|1⟩)
            InitializeQubits(inputBasis, inputValue, auxiliary, resource, target);
            AssertMeasurement([inputBasis], [target], One, "Target qubit is not in |1⟩ state.");
            let (success, numIter) = ApplyRzArcTan2(inputBasis, inputValue, limit, auxiliary, resource, target);
            Rz(2.0 * ArcTan(2.0), target); // Rotate back to initial state

            if (success == true) {
                AssertMeasurement([PauliX], [auxiliary], Zero, "Auxiliary qubit is not in |-⟩ state.");
                AssertMeasurement([PauliX], [resource], Zero, "Resource qubit is not in |-⟩ state.");
                AssertMeasurement([inputBasis], [target], One, "Target qubit is not in 1 state for the given basis.");
            }

            // Since the qubits used in this test aren't measured but
            // rather are asserted, we need to reset them manually.
            ResetAll([auxiliary, resource, target]);
        }
    }
}
