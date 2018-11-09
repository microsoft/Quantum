// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.



namespace Microsoft.Quantum.Canon
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;

    /// # Summary
    /// Given an $n$-qubit quantum state $\ket{\psi}=\sum^{2^n-1}_{j=0}\alpha_j \ket{j}$, 
    /// asserts that the probability $|\alpha_j|^2$ of the state $\ket{j}$ indexed by $j$ 
    /// has the expected value.
    ///
    /// # Input
    /// ## stateIndex
    /// The index $j$ of the state $\ket{j}$ represented by a `LittleEndian` 
    /// register.
    ///
    /// ## expected
    /// The expected value of $|\alpha_j|^2$.
    ///
    /// ## qubits
    /// The qubit register that stores $\ket{\psi}$ in little-endian format.
    ///
    /// ## tolerance
    /// Absolute tolerance on the difference between actual and expected.
    ///
    /// # Example
    /// Suppose that the `qubits` register encodes a 3-qubit quantum state 
    /// $\ket{\psi}=\sqrt{1/8}\ket{0}+\sqrt{7/8}\ket{6}$ in little-endian format.
    /// This means that the number states $\ket{0}\equiv\ket{0}\ket{0}\ket{0}$
    /// and $\ket{6}\equiv\ket{0}\ket{1}\ket{1}$. Then the following asserts succeed:
    /// - `AssertProbInt(0,0.125,qubits,10e-10);`
    /// - `AssertProbInt(6,0.875,qubits,10e-10);`
    operation AssertProbInt(stateIndex: Int, expected: Double, qubits: LittleEndian, tolerance: Double) : () {
        body{
            let nQubits = Length(qubits);
            let bits = BoolArrFromPositiveInt(stateIndex, nQubits);

            using(flag = Qubit[1]){
                (ControlledOnBitString(bits, X))(qubits, flag[0]);
                AssertProb([PauliZ], flag, One, expected, $"AssertProbInt failed on stateIndex {stateIndex}, expected probability {expected}.", tolerance);
                
                //Uncompute flag qubit.
                (ControlledOnBitString(bits, X))(qubits, flag[0]);
                ResetAll(flag);
            }
        }
    }

    /// # Summary
    /// Given an $n$-qubit quantum state $\ket{\psi}=\sum^{2^n-1}_{j=0}\alpha_j \ket{j}$, 
    /// asserts that the probability $|\alpha_j|^2$ of the state $\ket{j}$ indexed by $j$ 
    /// has the expected value.
    ///
    /// # Input
    /// ## stateIndex
    /// The index $j$ of the state $\ket{j}$ represented by a `BigEndian` 
    /// register.
    ///
    /// ## expected
    /// The expected value of $|\alpha_j|^2$.
    ///
    /// ## qubits
    /// The qubit register that stores $\ket{\psi}$ in big-endian format.
    ///
    /// ## tolerance
    /// Absolute tolerance on the difference between actual and expected.
    ///
    /// # Example
    /// Suppose that the `qubits` register encodes a 3-qubit quantum state 
    /// $\ket{\psi}=\sqrt{1/8}\ket{0}+\sqrt{7/8}\ket{6}$ in big-endian format.
    /// This means that the number states $\ket{0}\equiv\ket{0}\ket{0}\ket{0}$
    /// and $\ket{6}\equiv\ket{1}\ket{1}\ket{0}$. Then the following asserts succeed:
    /// - `AssertProbIntBE(0,0.125,qubits,10e-10);`
    /// - `AssertProbIntBE(6,0.875,qubits,10e-10);`
    operation AssertProbIntBE(stateIndex: Int, prob: Double, qubits: BigEndian, tolerance: Double) : () {
        body{
            let qubitsLE = LittleEndian(Reverse(qubits));
            AssertProbInt(stateIndex, prob, qubitsLE, tolerance);
        }
    }

    /// # Summary
    /// Asserts that the phase $\phi$ of an equal superposition quantum state 
    /// that may be expressed as
    /// $\frac{e^{i t}}{\sqrt{2}}(e^{i\phi}\ket{0} + e^{-i\phi}\ket{1})$
    /// for some arbitrary real t has the expected value.
    ///
    /// # Input
    /// ## expected
    /// The expected value of $\phi \in (-\pi,\pi]$.
    ///
    /// ## qubit
    /// The qubit that stores the expected state.
    ///
    /// ## tolerance
    /// Absolute tolerance on the difference between actual and expected.
    ///
    /// # Example
    /// The following assert succeeds:
    /// `qubit` is in state $\ket{\psi}=e^{i 0.5}\sqrt{1/2}\ket{0}+e^{i 0.5}\sqrt{1/2}\ket{1}$;
    /// - `AssertPhase(0.0,qubit,10e-10);`
    ///
    /// `qubit` is in state $\ket{\psi}=e^{i 0.5}\sqrt{1/2}\ket{0}+e^{-i 0.5}\sqrt{1/2}\ket{1}$;
    /// - `AssertPhase(0.5,qubit,10e-10);`
    ///
    /// `qubit` is in state $\ket{\psi}=e^{-i 2.2}\sqrt{1/2}\ket{0}+e^{i 0.2}\sqrt{1/2}\ket{1}$;
    /// - `AssertPhase(-1.2,qubit,10e-10);`
    operation AssertPhase(expected: Double, qubit: Qubit, tolerance: Double) : () {
        body{
            let expectedProbX = Cos(expected)*Cos(expected);
            let expectedProbY = Sin(-1.0*expected+PI()/4.0)*Sin(-1.0*expected+PI()/4.0);
            AssertProb([PauliZ], [qubit], Zero, 0.5, $"AssertPhase failed. Was not given a uniform superposition.",  tolerance);
            AssertProb([PauliY], [qubit], Zero, expectedProbY, $"AssertPhase failed. PauliY Zero basis did not give probability {expectedProbY}.",  tolerance);
            AssertProb([PauliX], [qubit], Zero, expectedProbX, $"AssertPhase failed. PauliX Zero basis did not give probability {expectedProbX}.",  tolerance);
        }
    }
}
