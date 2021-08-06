// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Chemistry.Samples {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Chemistry.JordanWigner;


    //////////////////////////////////////////////////////////////////////////
    // Using Trotter–Suzuki //////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// This allocates qubits and applies a single Trotter step.
    operation RunTrotterStep (qSharpData: JordanWignerEncodingData) : Unit {

        // The data describing the Hamiltonian for all these steps is contained in
        // `qSharpData`
        // We use a product formula, also known as the Trotter–Suzuki decomposition,
        // to simulate the Hamiltonian.
        // The integrator step size does not affect the gate cost of a single step.
        let trotterStepSize = 1.0;

        // Order of integrator
        let trotterOrder = 1;
        let (nQubits, (rescaleFactor, oracle)) = TrotterStepOracle(qSharpData, trotterStepSize, trotterOrder);

        // We not allocate qubits an run a single step.
        use qubits = Qubit[nQubits];
        oracle(qubits);
        ResetAll(qubits);
    }


    //////////////////////////////////////////////////////////////////////////
    // Using Qubitization ////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// This allocates qubits and applies a single qubitization step.
    operation RunQubitizationStep (qSharpData: JordanWignerEncodingData) : Double {

        // The data describing the Hamiltonian for all these steps is contained in
        // `qSharpData`
        let (nQubits, (l1Norm, oracle)) = QubitizationOracle(qSharpData);

        // We now allocate qubits and run a single step.
        use qubits = Qubit[nQubits];
        oracle(qubits);
        ResetAll(qubits);

        return l1Norm;
    }


    //////////////////////////////////////////////////////////////////////////
    // Using T-count optimized Qubitization //////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// We can now use Canon's phase estimation algorithms to
    /// learn the ground state energy using the above simulation.
    operation RunOptimizedQubitizationStep (qSharpData: JordanWignerEncodingData, targetError : Double) : Double {

        // The data describing the Hamiltonian for all these steps is contained in
        // `qSharpData`
        let (nQubits, (l1Norm, oracle)) = OptimizedQubitizationOracle(qSharpData, targetError);

        // We now allocate qubits and run a single step.
        use qubits = Qubit[nQubits];
        oracle(qubits);
        ResetAll(qubits);

        return l1Norm;
    }

}
