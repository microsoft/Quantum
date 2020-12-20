namespace Gaussian_initial_state {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Arithmetic;

    /// Single term in the normalization factor
    operation norm_term (sigma: Double, mu: Double, N: Int) : Double {
        let n = IntAsDouble(N);
        return ExpD(-((n-mu)^2.)/sigma^2.);
    }

    /// Normalization factor
    operation norm (sigma: Double, mu: Double, N: Int) : Double {
        mutable sum = 0.;
        for (n in -N..N) {
            set sum = PlusD(sum, norm_term(sigma, mu, n));
        }
        return sum;
    }

    /// Angle
    operation angle (sigma: Double, mu: Double, N : Int) : Double {
        return ArcCos(Sqrt(norm(sigma/2., mu/2., N)/norm(sigma, mu, N)));
    }

    /// Return a list of n-bit strings
    operation qubit_strings (n: Int) : Bool[][] {
        mutable array = ConstantArray(2^n, IntAsBoolArray(0,n));
        for (i in 0..2^n - 1) {
            let bitstring = IntAsBoolArray(i,n);
            set array w/= i <- bitstring;
        }
        return array;
    }

    /// Given an n-bit string, return the corresponding mean for the rotation angle
    /// at recursion level n
    operation mean_qubit_combo (qub: Bool[], mu: Double) : Double {
        mutable mu_out = mu;
        for (bit in qub) {
            mutable i = 0.0;
            if (bit == true) {
                set i = 1.;
            }
            set mu_out = mu_out/2. - i/2.;
        }
        return mu_out;
    }

    /// At recursion level n, return a list of all the means used for the various rotation angles
    operation level_means (mu: Double, n: Int) : Double[] {
        mutable list_mu_out = ConstantArray(2^n, 0.);
        let qb_strings = qubit_strings(n);
        for (i in 0..2^n-1) {
            let mu_out = mean_qubit_combo(ElementAt(i, qb_strings), mu);
            set list_mu_out w/= i <- mu_out;
        }
        return list_mu_out;
    }

    /// At recursion level n, return a list of all the rotation angles
    operation level_angles(sigma: Double, mu: Double, n: Int) : Double[] {
        let sigma_out = sigma/(2.^IntAsDouble(n));
        let list_mu = level_means(mu, n);
        mutable angles_out = ConstantArray(2^n, 0.);
        for (i in IndexRange(list_mu)) {
            mutable mu_ = ElementAt(i, list_mu);
            set angles_out w/= i <- angle(sigma_out, mu_, 10^3);
        }
        return angles_out;
    }

    operation gauss_wavefcn (sigma: Double, mu_: Double, num_qubits: Int) : Unit {
        using (register = Qubit[num_qubits]) {
            mutable theta = angle(sigma, mu_, 10^3);
            Ry(2.*theta, register[0]);
            for (n in 1..num_qubits-1) {
                let list_level_angles = level_angles(sigma, mu_, n);
                for (i in 0..2^n - 1){
                    let bitstring = IntAsBoolArray(i,n);
                    set theta = list_level_angles[i];
                    mutable rotation = Ry(2.*theta, _);
                    ApplyControlledOnBitString(bitstring, rotation, register[0..n-1], register[n]);                    
                }
            }
            DumpRegister("wavefcn.txt", register);
            ///DumpMachine("wavefcn.txt");
            ResetAll(register);
        }
    }    
}