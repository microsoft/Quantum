// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.IntegerFactorization {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Diagnostics;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Introduction ///////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // This sample contains Q# code implementing Shor's quantum algorithm for
    // factoring integers. The underlying modular arithmetic is implemented
    // in phase encoding, based on a paper by Stephane Beauregard who gave a
    // quantum circuit for factoring n-bit numbers that needs 2n+3 qubits and
    // O(n³log(n)) elementary quantum gates.

    /// # Summary
    /// Uses Shor's algorithm to factor the parameter `number`
    ///
    /// # Input
    /// ## number
    /// An integer to be factored
    /// ## useRobustPhaseEstimation
    /// If set to true, we use Microsoft.Quantum.Characterization.RobustPhaseEstimation and
    /// Microsoft.Quantum.Characterization.QuantumPhaseEstimation otherwise
    ///
    /// # Output
    /// Pair of numbers p > 1 and q > 1 such that p⋅q = `number`
    operation FactorInteger(number : Int, useRobustPhaseEstimation : Bool) : (Int, Int) {

        // First check the most trivial case, if the provided number is even
        if (number % 2 == 0) {
            Message("An even number has been passed; 2 is the factor.");
            return (number / 2, 2);
        }

        // Next try to guess a number co-prime to `number`
        // Get a random integer in the interval [1,number-1]
        let coprimeCandidate = RandomInt(number - 2) + 1;

        // Check if the random integer indeed co-prime using
        // Microsoft.Quantum.Math.IsCoprimeI.
        // If true use Quantum algorithm for Period finding.
        if (IsCoprimeI(coprimeCandidate, number)) {

            // Print a message using Microsoft.Quantum.Intrinsic.Message
            // indicating that we are doing something quantum.
            Message($"Estimating period of {coprimeCandidate}");

            // Call Quantum Period finding algorithm for
            // `coprimeCandidate` mod `number`.
            // Here we have a choice which Phase Estimation algorithm to use.
            let period = EstimatePeriod(coprimeCandidate, number, useRobustPhaseEstimation);

            // Period finding reduces to factoring only if period is even
            if (period % 2 == 0) {

                // Compute `coprimeCandidate` ^ `period/2` mod `number`
                // using Microsoft.Quantum.Math.ExpModI.
                let halfPower = ExpModI(coprimeCandidate, period / 2, number);

                // If we are unlucky, halfPower is just -1 mod N,
                // This is a trivial case not useful for factoring
                if (halfPower != number - 1) {

                    // When the halfPower is not -1 mod N
                    // halfPower-1 or halfPower+1 share non-trivial divisor with `number`.
                    // We find a divisor Microsoft.Quantum.Math.GreatestCommonDivisorI.
                    let factor = MaxI(GreatestCommonDivisorI(halfPower - 1, number), GreatestCommonDivisorI(halfPower + 1, number));

                    // Return computed non-trivial factors.
                    return (factor, number / factor);
                } else {
                    // Report the failure of hitting a trivial case.
                    // We have to start over again.
                    fail "Residue xᵃ = -1 (mod N) where a is a period.";
                }
            } else {
                // When period is odd we have to pick another number to estimate
                // period of and start over.
                fail "Period is odd.";
            }
        }
        // In this case we guessed a divisor by accident
        else {
            // Find a divisor using Microsoft.Quantum.Math.GreatestCommonDivisorI
            let gcd = GreatestCommonDivisorI(number, coprimeCandidate);

            // And do not forget to tell the user that we were lucky and didn't do anything
            // quantum using Microsoft.Quantum.Intrinsic.Message
            Message($"We have guessed a divisor of {number} to be {gcd} by accident.");

            // Return the factorization
            return (gcd, number / gcd);
        }
    }


    /// # Summary
    /// Interprets `target` as encoding unsigned little-endian integer k
    /// and performs transformation |k⟩ ↦ |gᵖ⋅k mod N ⟩ where
    /// p is `power`, g is `generator` and N is `modulus`.
    ///
    /// # Input
    /// ## generator
    /// The unsigned integer multiplicative order ( period )
    /// of which is being estimated. Must be co-prime to `modulus`.
    /// ## modulus
    /// The modulus which defines the residue ring Z mod `modulus`
    /// in which the multiplicative order of `generator` is being estimated.
    /// ## power
    /// Power of `generator` by which `target` is multiplied.
    /// ## target
    /// Register interpreted as LittleEndian which is multiplied by
    /// given power of the generator. The multiplication is performed modulo
    /// `modulus`.
    operation ApplyOrderFindingOracle(generator : Int, modulus : Int, power : Int, target : Qubit[])
    : Unit
    is Adj + Ctl {
        // Check that the parameters satisfy the requirements.
        Fact(IsCoprimeI(generator, modulus), "`generator` and `modulus` must be co-prime");

        // The oracle we use for order finding essentially wraps
        // Microsoft.Quantum.Arithmetic.MultiplyByModularInteger operation
        // that implements |x⟩ ↦ |x⋅a mod N ⟩.
        // We also use Microsoft.Quantum.Math.ExpModI to compute a by which
        // x must be multiplied.
        // Also note that we interpret target as unsigned integer
        // in little-endian encoding by using Microsoft.Quantum.Arithmetic.LittleEndian
        // type.
        MultiplyByModularInteger(ExpModI(generator, power, modulus), modulus, LittleEndian(target));
    }


    /// # Summary
    /// Finds a multiplicative order of the generator
    /// in the residue ring Z mod `modulus`.
    ///
    /// # Input
    /// ## generator
    /// The unsigned integer multiplicative order ( period )
    /// of which is being estimated. Must be co-prime to `modulus`.
    /// ## modulus
    /// The modulus which defines the residue ring Z mod `modulus`
    /// in which the multiplicative order of `generator` is being estimated.
    /// ## useRobustPhaseEstimation
    /// If set to true, we use Microsoft.Quantum.Characterization.RobustPhaseEstimation and
    /// Microsoft.Quantum.Characterization.QuantumPhaseEstimation
    ///
    /// # Output
    /// The period ( multiplicative order ) of the generator mod `modulus`
    operation EstimatePeriod(generator : Int, modulus : Int, useRobustPhaseEstimation : Bool) : Int {
        // Here we check that the inputs to the EstimatePeriod operation are valid.
        EqualityFactB(IsCoprimeI(generator, modulus), true, "`generator` and `modulus` must be co-prime");

        // The variable that stores the divisor of the generator period found so far.
        mutable result = 1;

        // Number of bits in the modulus with respect to which we are estimating the period.
        let bitsize = BitSizeI(modulus);

        // The EstimatePeriod operation estimates the period r by finding an
        // approximation k/2^bitsPrecision to a fraction s/r where s is some integer.
        // Note that if s and r have common divisors we will end up recovering a divisor of r
        // and not r itself. However, if we recover enough divisors of r
        // we recover r itself pretty soon.

        // Number of bits of precision with which we need to estimate s/r to recover period r.
        // using continued fractions algorithm.
        let bitsPrecision = 2 * bitsize + 1;

        repeat {

            // The variable that stores numerator of dyadic fraction k/2^bitsPrecision
            // approximating s/r
            mutable dyadicFractionNum = 0;

            // Allocate qubits for the superposition of eigenstates of
            // the oracle that is used in period finding
            using (eigenstateRegister = Qubit[bitsize]) {

                // Initialize eigenstateRegister to 1 which is a superposition of
                // the eigenstates we are estimating the phases of.
                // We first interpret the register as encoding unsigned integer
                // in little endian encoding.
                let eigenstateRegisterLE = LittleEndian(eigenstateRegister);
                ApplyXorInPlace(1, eigenstateRegisterLE);

                // An oracle of type Microsoft.Quantum.Oracles.DiscreteOracle
                // that we are going to use with phase estimation methods below.
                let oracle = DiscreteOracle(ApplyOrderFindingOracle(generator, modulus, _, _));

                // Find the numerator of a dyadic fraction that approximates
                // s/r where r is the multiplicative order ( period ) of g
                if (useRobustPhaseEstimation) {
                    // Use Microsoft.Quantum.Characterization.RobustPhaseEstimation to estimate s/r.
                    // RobustPhaseEstimation needs only one extra qubit, but requires
                    // several calls to the oracle
                    let phase = RobustPhaseEstimation(bitsPrecision, oracle, eigenstateRegisterLE!);

                    // Compute the numerator k of dyadic fraction k/2^bitsPrecision
                    // approximating s/r. Note that phase estimation project on the eigenstate
                    // corresponding to random s.
                    set dyadicFractionNum = Round(((phase * IntAsDouble(2 ^ bitsPrecision)) / 2.0) / PI());
                } else {
                    // Use Microsoft.Quantum.Characterization.QuantumPhaseEstimation to estimate s/r.
                    // When using QuantumPhaseEstimation we will need extra `bitsPrecision`
                    // qubits
                    using (register = Qubit[bitsPrecision]) {
                        let dyadicFractionNumerator = LittleEndian(register);

                        // The register that will contain the numerator k of
                        // dyadic fraction k/2^bitsPrecision. The numerator is unsigned
                        // integer encoded in big-endian format. This is indicated by
                        // use of Microsoft.Quantum.Arithmetic.BigEndian type.
                        QuantumPhaseEstimation(oracle, eigenstateRegisterLE!, LittleEndianAsBigEndian(dyadicFractionNumerator));

                        // Directly measure the numerator k of dyadic fraction k/2^bitsPrecision
                        // approximating s/r. Note that phase estimation project on
                        // the eigenstate corresponding to random s.
                        set dyadicFractionNum = MeasureInteger(dyadicFractionNumerator);
                    }
                }

                // Return all the qubits used for oracle's eigenstate back to 0 state
                // using Microsoft.Quantum.Intrinsic.ResetAll
                ResetAll(eigenstateRegister);
            }

            // Sometimes we might measure all zeros state in Phase Estimation.
            // This is a failure and we need to start all over.
            if (dyadicFractionNum == 0) {
                fail "We measured 0 for the numerator";
            }

            // This will print our estimate of s/r to the standard output
            // using Microsoft.Quantum.Intrinsic.Message
            Message($"Estimated eigenvalue is {dyadicFractionNum}/2^{bitsPrecision}.");

            // Now we use Microsoft.Quantum.Math.ContinuedFractionConvergentI
            // function to recover s/r from dyadic fraction k/2^bitsPrecision.
            let (numerator, period) = (ContinuedFractionConvergentI(Fraction(dyadicFractionNum, 2 ^ bitsPrecision), modulus))!;

            // ContinuedFractionConvergentI does not guarantee the signs of the numerator
            // and denominator. Here we make sure that both are positive using
            // AbsI.
            let (numeratorAbs, periodAbs) = (AbsI(numerator), AbsI(period));

            // Use Microsoft.Quantum.Intrinsic.Message to output the
            // period divisor and the eigenstate number
            Message($"Estimated divisor of period is {periodAbs}, " + $" we have projected on eigenstate marked by {numeratorAbs}.");

            // Update the result variable by including newly found divisor.
            // Uses Microsoft.Quantum.Math.GreatestCommonDivisorI function from Microsoft.Quantum.Math.
            set result = (periodAbs * result) / GreatestCommonDivisorI(result, periodAbs);
        }
        until (ExpModI(generator, result, modulus) == 1)
        fixup {

            // Above we checked if we have found actual period, or only the divisor of it.
            // If the period was found, loop terminates.

            // If we have not found the period, output message about it to
            // standard output and try again.
            Message("It looks like the period has divisors and we have " + "found only a divisor of the period. Trying again ...");
        }

        // Return found period.
        return result;
    }

}
