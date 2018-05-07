namespace Microsoft.Quantum.Tests {

    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
	open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Testing;
	open Microsoft.Quantum.Extensions.Math;


    // # Sumary
    /// Assert that the QuantumPhaseEstimation operation for the T gate
	/// return 0000 in the controlRegister when targetState is 0 and
	/// return 0010 when the targetState is 1 
    operation QuantumPhaseEstimation_Test () : ()
    {
        body
        {
            let Oracle = DiscreteOracle(T_PhaseEstimation(_,_));
            using ( QPhase = Qubit[5]){
                let Phase = BigEndian(QPhase[0..3]);
                let State = QPhase[4];
                QuantumPhaseEstimation(Oracle,[State],Phase);
                let ComplexOne = Complex(1.,0.);
				let ComplexZero = Complex(0.,0.);
                for(idxPhase in 0..4){
                    AssertQubitState((ComplexOne,ComplexZero),QPhase[idxPhase],0.000001);
                }
                X(State);
                QuantumPhaseEstimation(Oracle,[State],Phase);
                AssertQubitState((ComplexOne,ComplexZero),QPhase[0],0.000001);
                AssertQubitState((ComplexOne,ComplexZero),QPhase[1],0.000001);
			    AssertQubitState((ComplexZero,ComplexOne),QPhase[2],0.000001);
			    AssertQubitState((ComplexOne,ComplexZero),QPhase[3],0.000001);
                AssertQubitState((ComplexZero,ComplexOne),QPhase[4],0.000001);
                ResetAll(QPhase);
			}
		}
    }

    operation T_PhaseEstimation (Power: Int, Target: Qubit[]) : ()
    {
        body
        {
            for(i in 0..Power-1){
                T(Target[0]);
            }
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }
}
