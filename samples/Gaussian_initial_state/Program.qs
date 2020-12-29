namespace Gaussian_initial_state {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic; 
    open Microsoft.Quantum.Arrays;

    @EntryPoint()
    operation RunProgram() : Unit {
        let N = 7;
        let std_dev = IntAsDouble((2^N))/6.;
        let mean = IntAsDouble(2^(N-1)) - 0.5;
        let bitstring = EmptyArray<Bool>();
        //Message(BoolAsString(IsEmpty(bitstring)));
        //let bitstring0 = Flattened([bitstring, [false]]);
        //Message(BoolAsString(IsEmpty(bitstring0)));
        //Message(IntAsString(Length(bitstring0)));
        using (register = Qubit[N]) {
            gauss_wavefcn_recursive(std_dev, mean, N, bitstring, register);
            DumpRegister("wavefcn_recursive.txt", register);
            ResetAll(register);
        }
    }
}