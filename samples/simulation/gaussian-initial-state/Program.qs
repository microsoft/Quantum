// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.GaussianPreparation {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic; 
    open Microsoft.Quantum.Arrays;

    @EntryPoint()
    operation RunProgram(recursive : Bool, nQubits : Int) : Unit {
        let stdDev = IntAsDouble(2 ^ nQubits) / 6.;
        let mean = IntAsDouble(2 ^ (nQubits - 1)) - 0.5;
        let bitstring = EmptyArray<Bool>();
        use register = Qubit[nQubits];
        // Call the recursive implementation.
        if recursive {
            PrepareGaussianWavefunctionRecursive(stdDev, mean, nQubits, bitstring, register);
        } else {
            PrepareGaussianWavefunction(stdDev, mean, register);
        }
        // Output the resulting quantum state.
        DumpRegister((), register);
        ResetAll(register);
    }
}
