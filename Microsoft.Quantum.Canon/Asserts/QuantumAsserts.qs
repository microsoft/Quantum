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
    /// asserts that the probability $|\alpha_j|^2$ of the state indexed by $j$ 
    /// has the expected value.
    ///
    /// # Input
    /// ## integer
    /// The integer $j$ indexing state $\ket{j}$.
    ///
    /// ## expected
    /// The expected value of $|\alpha_j|^2$.
    ///
    /// ## qubits
    /// The qubit register that stores $\ket{\psi}$ in little-endian format.
    ///
    /// ## tolerance
    /// Absolute tolerance on the difference between actual and expected.
    operation AssertProbInt(integer: Int, expected: Double, qubits: LittleEndian, tolerance: Double) : () {
        body{
            let nQubits = Length(qubits);
            let bits = BoolArrFromPositiveInt(integer, nQubits);

            using(flag = Qubit[1]){
                (ControlledOnBitString(bits, X))(qubits, flag[0]);
                AssertProb([PauliZ], flag, One, expected, $"AssertProbInt failed on integer {integer}, expected probability {expected}.", tolerance);
                
                //Uncompute flag qubit.
                (ControlledOnBitString(bits, X))(qubits, flag[0]);
                ResetAll(flag);
            }
        }
    }

    /// # Summary
    /// Given an $n$-qubit quantum state $\ket{\psi}=\sum^{2^n-1}_{j=0}\alpha_j \ket{j}$, 
    /// asserts that the probability $|\alpha_j|^2$ of the state indexed by $j$ 
    /// has the expected value.
    ///
    /// # Input
    /// ## integer
    /// The integer $j$ indexing state $\ket{j}$.
    ///
    /// ## expected
    /// The expected value of $|\alpha_j|^2$.
    ///
    /// ## qubits
    /// The qubit register that stores $\ket{\psi}$ in big-endian format.
    ///
    /// ## tolerance
    /// Absolute tolerance on the difference between actual and expected.
    operation AssertProbIntBE(integer: Int, prob: Double, qubits: BigEndian, tolerance: Double) : () {
        body{
            let qubitsLE = LittleEndian(Reverse(qubits));
            AssertProbInt(integer, prob, qubitsLE, tolerance);
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
    /// The expected value of $\phi$.
    ///
    /// ## qubit
    /// The qubit that stores the expected state.
    ///
    /// ## tolerance
    /// Absolute tolerance on the difference between actual and expected.
    operation AssertPhase(expected: Double, qubit: Qubit, tolerance: Double) : () {
        body{
            let exptectedProbX = Cos(expected)*Cos(expected);
            let exptectedProbY = Sin(-1.0*expected+PI()/4.0)*Sin(-1.0*expected+PI()/4.0);
            AssertProb([PauliZ], [qubit], Zero, 0.5, $"AssertPhase Failed. Was not given a uniform superposition.",  tolerance);
            AssertProb([PauliY], [qubit], Zero, exptectedProbY, $"AssertPhase Failed. PauliY Zero basis did not give probability {exptectedProbY}.",  tolerance);
            AssertProb([PauliX], [qubit], Zero, exptectedProbX, $"AssertPhase Failed. PauliX Zero basis did not give probability {exptectedProbX}.",  tolerance);
        }
    }
}
