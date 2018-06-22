namespace Microsoft.Quantum.Tests {

    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Testing;
    open Microsoft.Quantum.Extensions.Math;

    /// # Summary
    /// Assert that the QuantumPhaseEstimation operation for the T gate
    /// return 0000 in the controlRegister when targetState is 0 and
    /// return 0010 when the targetState is 1  
    operation QuantumPhaseEstimationTest () : ()
    {
        body
        {
            let oracle = DiscreteOracle(_TPhaseEstimation);
            using ( qPhase = Qubit[5]){
                let phase = BigEndian(qPhase[0..3]);
                let state = qPhase[4];
                QuantumPhaseEstimation(oracle,[state],phase);
                let complexOne = Complex(1.,0.);
                let complexZero = Complex(0.,0.);
                for(idxPhase in 0..4){
                    AssertQubitState((complexOne,complexZero),qPhase[idxPhase],0.000001);
                }
                X(state);
                QuantumPhaseEstimation(oracle,[state],phase);
                AssertQubitState((complexOne,complexZero),qPhase[0],0.000001);
                AssertQubitState((complexOne,complexZero),qPhase[1],0.000001);
                AssertQubitState((complexZero,complexOne),qPhase[2],0.000001);
                AssertQubitState((complexOne,complexZero),qPhase[3],0.000001);
                AssertQubitState((complexZero,complexOne),qPhase[4],0.000001);
                ResetAll(qPhase);
            }
        }
    }

    /// # Summary
    /// Implementation of T-gate for Quantum Phase Estimation Oracle
    operation _TPhaseEstimation (power: Int, target: Qubit[]) : ()
    {
        body
        {
            for(idxPower in 0..power-1){
                T(target[0]);
            }
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }
}
