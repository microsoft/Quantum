// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.GaussianPreparation {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Arithmetic;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // This program prepares a quantum state that encodes a Gaussian function using
    // probability amplitudes, given the standard deviation, mean, and number of
    // qubits.

    //////////////////////////////////////////////////////////////////////////
    // Gaussian initial state ////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// Computes a single term in the normalization factor.
    /// # Input
    /// ## sigma
    /// Standard deviation.
    /// ## mu
    /// Mean.
    /// ## N
    /// The term in the normalization factor.
    function NormTerm(sigma : Double, mu : Double, N : Int) : Double {
        let n = IntAsDouble(N);
        return ExpD(-((n - mu) ^ 2.) / sigma ^ 2.);
    }

    /// # Summary
    /// Computes the normalization factor.
    /// # Input
    /// ## sigma
    /// Standard deviation.
    /// ## mu
    /// Mean.
    /// ## N
    /// The limit of the sum in the normalization factor.
    function Norm(sigma : Double, mu : Double, N : Int) : Double {
        mutable sum = 0.;
        for n in -N..N {
            set sum += NormTerm(sigma, mu, n);
        }
        return sum;
    }

    /// # Summary
    /// Computes the rotation angle.
    /// # Input
    /// ## sigma
    /// Standard deviation.
    /// ## mu
    /// Mean.
    /// ## N
    /// The limit of the sum in the normalization factor.
    function Angle(sigma: Double, mu: Double, N : Int) : Double {
        return ArcCos(Sqrt(Norm(sigma / 2., mu / 2., N) / Norm(sigma, mu, N)));
    }

    /// # Summary
    /// Return a list of n-bit strings.
    /// # Input
    /// ## nQubits
    /// The number of bits.
    function QubitStrings(nQubits : Int) : Bool[][] {
        return MappedOverRange(IntAsBoolArray(_, nQubits), 0..PowI(2, nQubits) - 1);
    }


    /// # Summary
    /// Given an n-bit string, return the corresponding mean for the rotation angle
    /// at recursion level n.
    ///
    /// # Input
    /// ## qub
    /// The n-bit string.
    /// ## mu
    /// Mean.
    function MeanQubitCombo(qub : Bool[], mu : Double) : Double {
        mutable muOut = mu;
        for bit in qub {
            set muOut += muOut / 2. - (bit ? 0. | -0.5);
        }
        return muOut;
    }

    /// # Summary
    /// At recursion level n, return a list of all the means used for the various rotation angles.
    ///
    /// # Input
    /// ## mu
    /// Mean.
    /// ## n
    /// Recursion level.
    function LevelMeans(mu : Double, n : Int) : Double[] {
        let qbStrings = QubitStrings(n);
        return Mapped(MeanQubitCombo(_, mu), qbStrings);
    }


    /// # Summary
    /// At recursion level n, return a list of all the rotation angles.
    /// # Input
    /// ## sigma
    /// Standard deviation
    /// ## mu
    /// Mean.
    /// ## n
    /// Recursion level.
    function LevelAngles(sigma : Double, mu : Double, n : Int) : Double[] {
        let sigmaOut = sigma / (2. ^ IntAsDouble(n));
        let anglesOut = Mapped(
            Angle(sigmaOut, _, 10^3),
            LevelMeans(mu, n)
        );
        return anglesOut;
    }

    /// # Summary
    /// Prepare the Gaussian wavefunction on a register.
    /// # Input
    /// ## sigma
    /// Standard deviation.
    /// ## mu
    /// Mean.
    /// ## num_qubits
    /// The number of qubits.
    operation PrepareGaussianWavefunction(sigma : Double, mu : Double, register : Qubit[]) : Unit is Adj {
        // Compute angle.
        mutable theta = Angle(sigma, mu, 10^3);
        // Rotate the 1st qubit by angle theta.
        Ry(2. * theta, register[0]);
        for n in 1..Length(register) - 1 {
            // Compute a list of all the rotation angles at level n.
            let listLevelAngles = LevelAngles(sigma, mu, n);
            // For each bitstring at current level, apply a controlled rotation to the
            // next qubit.
            for i in 0..2^n - 1 {
                let bitstring = IntAsBoolArray(i,n);
                let rotation = Ry(2. * listLevelAngles[i], _);
                ApplyControlledOnBitString(bitstring, rotation, register[0..n-1], register[n]);
            }
        }
    }

    /// # Summary
    /// Prepare the Gaussian wavefunction on a register using the recursive implementation.
    /// # Input
    /// ## sigma
    /// Standard deviation.
    /// ## mu
    /// Mean.
    /// ## nQubits
    /// The number of qubits.
    /// ## bitstring
    /// An empty bitstring.
    /// ## register
    /// The qubit register.
    operation PrepareGaussianWavefunctionRecursive(
        sigma : Double, mu : Double, nQubits : Int, bitstring: Bool[],
        register : Qubit[]
    )
    : Unit is Adj {
        let rotateByAlpha = Ry(2. * Angle(sigma, mu, 10^3), _);

        // If the number of qubits is 1, then simply do a rotation to the qubit.
        if nQubits == 1 {
		    rotateByAlpha(register[0]);
        }

        // If there's more than 1 qubit, construct the state recursively.
        elif nQubits > 1 {
            // If there's a single qubit, then simply do a rotation.
            if IsEmpty(bitstring) or nQubits == 1 {
                // Rotate the 1st qubit.
                rotateByAlpha(register[0]);
            }
            // If the bitstring is not empty but not longer than the number of qubits, or
            // it's not the 1st qubit but not after the last qubit.
            elif Length(bitstring) < nQubits {
                // Apply the controlled rotation with the bitstring to the next qubit.
                let n = Length(bitstring);
                ApplyControlledOnBitString(bitstring, rotateByAlpha, register[0..n - 1], register[n]);
            }

            if Length(bitstring) != nQubits and nQubits != 1 {
                // Add a 0 to the bitstring and call the function recursively.
                let bitstring0 = bitstring + [false];
                PrepareGaussianWavefunctionRecursive(sigma / 2., mu / 2., nQubits, bitstring0, register);
                // Add a 1 to the bitstring and call the function recursively.
                let bitstring1 = bitstring + [true];
                PrepareGaussianWavefunctionRecursive(sigma / 2., (mu - 1.) / 2., nQubits, bitstring1, register);
            }
        }

    }

}
