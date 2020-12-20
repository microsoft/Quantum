namespace Gaussian_initial_state {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic; 

    @EntryPoint()
    operation RunProgram() : Unit {
        let N = 7;
        let std_dev = IntAsDouble((2^N))/6.;
        let mean = IntAsDouble(2^(N-1)) - 0.5;
        gauss_wavefcn(std_dev, mean, N);
    }
}