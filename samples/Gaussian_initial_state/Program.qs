namespace Microsoft.Quantum.Samples.GaussianPreparation {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic; 
    open Microsoft.Quantum.Arrays;

    @EntryPoint()
    operation RunProgram() : Unit {
        let N = 7;
        let stdDev = IntAsDouble((2 ^ N)) / 6.;
        let mean = IntAsDouble(2^(N-1)) - 0.5;
        let bitstring = EmptyArray<Bool>();
        // Call the for loop implementation.
        // Gauss_wavefcn(std_dev, mean, N);
        // Call the recursive implementation.
        using (register = Qubit[N]) {
            GaussWavefcnRecursive(std_dev, mean, N, bitstring, register);
            // Output result quantum state the file.
            DumpRegister("wavefcn_recursive.txt", register);
            ResetAll(register);
        }
    }
}
