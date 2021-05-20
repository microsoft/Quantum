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
        use register = Qubit[nQubits];
        // Call the recursive implementation.
        if recursive {
            PrepareGaussianWavefunctionRecursive(stdDev, mean, nQubits, [], register);
        } else {
            PrepareGaussianWavefunction(stdDev, mean, register);
        }

        // Output the resulting quantum state. Note that we use `()` here to
        // indicate that the simulator should dump to its default location
        // (typically, the console). This will allow the Python host program
        // to intercept the dump and provide a richer plot.
        DumpRegister((), register);

        // Reset all qubits before releasing them.
        ResetAll(register);
    }
}
