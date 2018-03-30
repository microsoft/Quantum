namespace Microsoft.Quantum.Canon
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;

    // TODO: Type specialization for LittleEndian, BigEndian.
    operation AssertProbInt(integer: Int, prob: Double, qubits: LittleEndian, tolerance: Double) : () {
        body{
            let nQubits = Length(qubits);
            let bits = BoolArrFromPositiveInt(integer, nQubits);

            using(flag = Qubit[1]){
                (ControlledOnBitString(bits, X))(qubits, flag[0]);
                AssertProb([PauliZ], flag, One, prob, $"AssertProbInt failed on integer {integer}, expected probability {prob}.", tolerance);
                Message($"AssertProbInt passed. Integer {integer} on {nQubits} qubits with probability {prob}.");
                
                //Uncompute flag qubit.
                (ControlledOnBitString(bits, X))(qubits, flag[0]);
                ResetAll(flag);
            }
        }
    }

    operation AssertProbIntBE(integer: Int, prob: Double, qubits: BigEndian, tolerance: Double) : () {
        body{
            let qubitsLE = LittleEndian(Reverse(qubits));
            AssertProbInt(integer, prob, qubitsLE, tolerance);
        }
    }

    // Given a state $(e^{ phi}\ket{0} + e^{- phi}\ket{1})/\sqrt(2)$, this asserts phi.
    operation AssertPhase(phase: Double, qubit: Qubit, tolerance: Double) : () {
        body{
            let exptectedProbX = Cos(phase)*Cos(phase);
            let exptectedProbY = Sin(-1.0*phase+PI()/4.0)*Sin(-1.0*phase+PI()/4.0);
            AssertProb([PauliZ], [qubit], Zero, 0.5, $"AssertPhase Failed. Was not given a uniform superposition.",  tolerance);
            AssertProb([PauliY], [qubit], Zero, exptectedProbY, $"AssertPhase Failed. PauliY Zero basis did not give probability {exptectedProbY}.",  tolerance);
            AssertProb([PauliX], [qubit], Zero, exptectedProbX, $"AssertPhase Failed. PauliX Zero basis did not give probability {exptectedProbX}.",  tolerance);
        }
    }
}
