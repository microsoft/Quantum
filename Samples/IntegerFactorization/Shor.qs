// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.IntegerFactorization
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Canon;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Introduction ///////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///
    /// This sample contains Q# code implementing Shor's quantum algorithm for
    /// factoring integers. The underlying modular arithmetic is implemented 
    /// in phase encoding, based on paper by Stephane Beauregard who gave a
    /// quantum circuit for factoring n-bit numbers that needs 2n+3 qubits and 
    /// O(n³log(n)) many elementary quantum gates.
    ///
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary 
    /// Uses Shor's algorithm to factor a `number`
    ///
    /// # Input 
    /// ## number
    /// An integer to be factored
    /// ## useRobustPhaseEstimation
    /// If set to true, we use Microsoft.Quantum.Canon.RobustPhaseEstimation and 
    /// Microsoft.Quantum.Canon.QuantumPhaseEstimation otherwise
    ///
    /// # Output 
    /// Pair of numbers p > 1 and q > 1 such that p⋅q = `number`
    operation Shor ( number : Int, useRobustPhaseEstimation : Bool ) : (Int,Int) {
        body
        {
            // First check the most trivial case, if the provided number is even
            if (  number % 2 == 0 ) {
                Message("An even number has been passed; 2 is the factor.");
                return (number / 2, 2);
            }

            // Next try to guess a number co-prime to `number`
            // Get a random integer in the interval [1,number-1]
            let coprimeCandidate = RandomInt(number - 2) + 1;

            // Check if the random integer indeed co-prime using 
            // Microsoft.Quantum.Canon.IsCoprime.
            // If true use Quantum algorithm for Period finding.
            if( IsCoprime(coprimeCandidate, number) ) {
                
                // Print a message using Microsoft.Quantum.Primitive.Message
                // indicating that we are doing something quantum.
                Message($"Estimating period of {coprimeCandidate}");

                // Call Quantum Period finding algorithm for 
                // `coprimeCandidate` mod `number`.
                // Here we have a choice which Phase Estimation algorithm to use.
                let period = EstimatePeriod(coprimeCandidate, number, useRobustPhaseEstimation);
                
                // Period finding reduces to factoring only if period is even
                if( period % 2 == 0 ) {

                    // Compute `coprimeCandidate` ^ `period/2` mod `number`
                    // using Microsoft.Quantum.ExpMod.
                    let halfPower = ExpMod(coprimeCandidate,period/2,number);

                    // If we are unlucky, halfPower is just -1 mod N, 
                    // This is a trivial case not useful for factoring
                    if( halfPower != number - 1 ) {

                        // When the halfPower is not -1 mod N 
                        // halfPower-1 or halfPower+1 share non-trivial divisor with `number`.
                        // We find a divisor Microsoft.Quantum.Canon.GCD.
                        let factor = MaxI(GCD(halfPower-1, number), GCD(halfPower+1, number));

                        // Return computed non-trivial factors.
                        return (factor,number/factor);
                    }
                    else {

                        // Report the failure of hitting a trivial case.
                        // We have to start over again.
                        fail "Residue xᵃ = -1 (mod N) where a is a period.";
                    }
                }
                else {
                    // When period is odd we have to pick another number to estimate 
                    // period of and start over.
                    fail "Period is odd.";
                }

                // This line will never be reached, however Q# compiler requires it here
                // as otherwise this looks like somebody forgot a return statement. 
                // C# is more advance and will show a warning: 
                // Warning	CS0162	Unreachable code detected ShorWithCanon.qs:71
                return (0,0);           
            }
            else { // In this case we guessed a divisor by accident
                // Find a divisor using Microsoft.Quantum.Canon.GCD
                let gcd = GCD(number,coprimeCandidate);

                // And do not forget to tell the user that we were lucky and didn't do anything 
                // quantum using Microsoft.Quantum.Primitive.Message
                Message($"We have guessed a divisor of {number} to be {gcd} by accident.");

                // Return the factorization
                return ( gcd, number / gcd );
            }
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
    operation OrderFindingOracle(
        generator : Int, modulus : Int, power : Int , target : Qubit[] ) : () {
        body {
            // Check that the parameters satisfy the requirements.
            AssertBoolEqual(
                IsCoprime(generator,modulus), true,
                "`generator` and `modulus` must be co-prime" );

            // The oracle we use for order finding essentially wraps 
            // Microsoft.Quantum.Canon.ModularMultiplyByConstantLE operation
            // that implements |x⟩ ↦ |x⋅a mod N ⟩.
            // We also use Quantum.Canon.ExpMod to compute a by which 
            // x must be multiplied.
            // Also note that we interpret target as unsigned integer 
            // in little-endian encoding by using Microsoft.Quantum.Canon.LittleEndian
            // type.
            ModularMultiplyByConstantLE(
                ExpMod(generator,power,modulus),
                modulus,
                LittleEndian(target)
                );
        }
        adjoint auto

        // Phase estimation routines use controlled version of the oracle
        // and therefore OrderFindingOracle must have a controlled version.
        // In this case compiler can easily figure out the controlled version.
        controlled auto
        adjoint controlled auto
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
    /// If set to true, we use Microsoft.Quantum.Canon.RobustPhaseEstimation and 
    /// Microsoft.Quantum.Canon.QuantumPhaseEstimation
    /// 
    /// # Output 
    /// The period ( multiplicative order ) of the generator mod `modulus`
    operation EstimatePeriod(
              generator : Int,
              modulus : Int,
              useRobustPhaseEstimation : Bool ): Int {
        body{
            // Here we check that the inputs to the EstimatePeriod operation are valid.
            AssertBoolEqual(
                IsCoprime(generator,modulus), true,
                "`generator` and `modulus` must be co-prime" );

            // The variable that stores the divisor of the generator period found so far.
            mutable result = 1;

            // Number of bits in the modulus with respect to which we are estimating the period.
            let bitsize = BitSize( modulus );

            // The EstimatePeriod operation estimates the period r by finding an 
            // approximation k/2^bitsPrecision to a fraction s/r where s is some integer.
            // Note that if s and r have common divisors we will end up recovering a divisor of r
            // and not r itself. However, if we recover big enough number of divisors of r
            // we recover r itself pretty soon.

            // Number of bits of precision with which we need to estimate s/r to recover period r.
            // using continued fractions algorithm. 
            let bitsPrecision = 2*bitsize + 1;

            repeat {
                // The variable that stores numerator of dyadic fraction k/2^bitsPrecision 
                // approximating s/r
                mutable dyadicFractionNum = 0;

                // Allocate qubits for the superposition of eigenstates of 
                // the oracle that is used in period finding
                using( eignestateRegister = Qubit[bitsize]  ) {

                    // Initialize eignestateRegister to 1 which is a superposition of 
                    // the eigenstates we are estimating the phases of. 
                    // We first interpret the register as encoding unsigned integer
                    // in little endian encoding.
                    let eignestateRegisterLE = LittleEndian(eignestateRegister);
                    InPlaceXorLE(1,eignestateRegisterLE);

                    // An oracle of type Microsoft.Quantum.Canon.DiscreteOracle 
                    // that we are going to use with phase estimation methods below.
                    let oracle = DiscreteOracle(OrderFindingOracle(generator,modulus,_,_));

                    // Find the numerator of a dyadic fraction that approximates 
                    // s/r where r is the multiplicative order ( period ) of g
                    if( useRobustPhaseEstimation )
                    {
                        // Use Microsoft.Quantum.Canon.RobustPhaseEstimation to estimate s/r.
                        // RobustPhaseEstimation needs only one extra qubit, but requires 
                        // several calls to the oracle
                        let phase = RobustPhaseEstimation(
                            bitsPrecision, 
                            oracle,
                            eignestateRegisterLE
                            );
                        
                        // Compute the numerator k of dyadic fraction k/2^bitsPrecision 
                        // approximating s/r. Note that phase estimation project on the eigenstate 
                        // corresponding to random s.
                        set dyadicFractionNum = 
                            Round( phase * ToDouble(2 ^ bitsPrecision  ) / 2.0 / PI() ) ;
                    }
                    else {
                        
                        // Use Microsoft.Quantum.Canon.QuantumPhaseEstimation to estimate s/r.
                        // When using QuantumPhaseEstimation we will need extra `bitsPrecision`
                        // qubits
                        using ( dyadicFractionNumerator = Qubit[bitsPrecision] ) {

                            // The register that will contain the numerator k of
                            // dyadic fraction k/2^bitsPrecision. The numerator is unsigned 
                            // integer encoded in big-endian format. This is indicated by 
                            // use of Microsoft.Quantum.Canon.BigEndian type.
                            let dyadicFractionNumeratorBE = BigEndian(dyadicFractionNumerator);

                            QuantumPhaseEstimation(
                                oracle,
                                eignestateRegisterLE,
                                dyadicFractionNumeratorBE);

                            // Directly measure the numerator k of dyadic fraction k/2^bitsPrecision 
                            // approximating s/r. Note that phase estimation project on 
                            // the eigenstate corresponding to random s.
                            set dyadicFractionNum = MeasureIntegerBE(dyadicFractionNumeratorBE);
                        }
                    }

                    // Return all the qubits used for oracle's eigenstate back to 0 state
                    // using Microsoft.Quantum.Canon.ResetAll
                    ResetAll(eignestateRegister);
                }

                // Sometimes we might measure all zeros state in Phase Estimation.
                // This is a failure and we need to start all over.
                if ( dyadicFractionNum == 0 ) {
                    fail "We measured 0 for the numerator";
                }

                // This will print our estimate of s/r to the standard output
                // using Microsoft.Quantum.Primitive.Message
                Message($"Estimated eigenvalue is {dyadicFractionNum}/2^{bitsPrecision}.");

                // Now we use Microsoft.Quantum.Canon.ContinuedFractionConvergent
                // function to recover s/r from dyadic fraction k/2^bitsPrecision.
                let (numerator,period) = 
                    ContinuedFractionConvergent(
                        Fraction(dyadicFractionNum, 2^(bitsPrecision)), 
                        modulus);

                // ContinuedFractionConvergent does not guarantee the signs of the numerator 
                // and denominator. Here we make sure that both are positive using 
                // Microsoft.Quantum.Extensions.MathI
                let (numeratorAbs,periodAbs) = (AbsI(numerator), AbsI(period));

                // Use Microsoft.Quantum.Primitive.Message to output the 
                // period divisor and the eigenstate number
                Message($"Estimated divisor of period is {periodAbs}, " +
                        $" we have projected on eigenstate marked by {numeratorAbs}.");

                // Update the result variable by including newly found divisor.
                // Uses GCD function from Microsoft.Quantum.Canon. 
                set result = periodAbs * result / GCD(result,periodAbs);
            }
            until( ExpMod(generator,result,modulus) == 1 )
            fixup {
                // Above we checked if we have found actual period, or only the divisor of it.
                // If the period was found, loop terminates.

                // If we have not found the period, output message about it to 
                // standard output and try again.
                Message($"It looks like the period has divisors and we have " + 
                        $"found only a divisor of the period. Trying again ...");
            }

            // Return found period.
            return result;
        }
    }
}
