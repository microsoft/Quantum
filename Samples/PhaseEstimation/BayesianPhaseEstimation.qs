// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.PhaseEstimation {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Extensions.Convert;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // This sample introduces iterative phase estimation, as well
    // as the algorithms for processing the results of iterative phase
    // estimation that are provided with Q#.

    // In phase estimation, one is concerned with learning the *eigenvalues*
    // of a unitary operator U. In particular, suppose that U is unknown, but
    // that we have access to U as an oracle. That is, we can call U as an
    // operation on a register of our choice, but cannot introspect into its
    // source code. Suppose as well that we also have access to an operation
    // which prepares a state |φ〉 such that U|φ〉 = e^{i φ} |φ〉 for some φ
    // that we would like to learn. Given these resources, we can learn φ by
    // applying either quantum or iterative phase estimation.

    //////////////////////////////////////////////////////////////////////////
    // Oracles for Phase Estimation //////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // Before proceeding further, it's helpful to take a moment to discuss
    // how to represent the phase estimation oracle U in our Q# programs.
    // The most straightforward representation is for any phase estimation
    // operation to take as an input a value of type
    // (Qubit[] => () : Controlled), representing an operation that acts on
    // an array of qubits and that can be controlled.

    // To implement U^m for some power m, we can use an operation of this form
    // inside of a for loop. This precludes, however, if we have a more
    // efficient implementation that would let us "fast forward."
    // By the no fast-forwarding theorem [https://arxiv.org/abs/0908.4398],
    // this cannot be done in general, such that if we only have oracular
    // access to U, we preclude significant opportunities for improvements.

    // A more general approach is thus to take an operation of type
    // ((Int, Qubit[]) => () : Controlled) representing U(m) ≔ U^m.
    // For oracular access to U, we write out the same for loop here, or use
    // the OperationPow function in the canon, while we remain compatible with
    // speedups in special cases.

    // As a further generalization, we can instead consider that U is not
    // a single unitary at all, but a family of unitaries parameterized by
    // time, |ψ(t)〉 = U(t) |ψ(0)〉. If these unitaries compose as U(t + s) =
    // U(t) U(s), then we can write that U(t) = e^{-i H t} for some operator
    // H, making this model ideal for application to Hamiltonian simulation.
    // In particular, we now have that |φ〉 is an eigenstate of H as well,
    // such that H|φ〉 = -φ|φ〉. Thus, phase estimation expressed in this form
    // learns the energy of a particular eigenstate of a Hamiltonian.
    // This generalization is represented in Q# as an operation of the type
    // ((Double, Qubit[]) => () : Controlled).

    // For the rest of this sample, we follow the continuous-time convention.

    //////////////////////////////////////////////////////////////////////////
    // Iterative Phase Estimation ////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // In the iterative case, one learns φ by using
    // a single additional qubit to turn phase estimation into a classical
    // statistical problem.

    // Given an operation representing U and an operation representing
    // preparation of |φ〉, we can implement each step of iterative phase estimation
    // by preparing a control qubit in the |+〉 state, controlling the application
    // of U(t) for some t : Double, and then measuring the control qubit in
    // the X basis.

    // The final measurement from a single step follows a sinusoidal
    // *likelihood function*, such that iterative phase estimation is readily
    // amenable to analysis by well-known methods such as Bayesian inference,
    // as we will detail below. For now, we define the phase estimation step
    // itself.

    // In practice, it can help dramatically improve numerical stability of
    // some algorithms if we also rotate the control qubit before using it
    // to control U. We thus include an additional input to allow
    // for this.

    /// # Summary
    /// Performs a single step of iterative phase estimation for a
    /// given oracle.
    ///
    /// # Input
    /// ## time
    /// Time to evolve under the oracle for during this iteration.
    /// ## inversionAngle
    /// An angle to rotate the control register by before applying
    /// the controlled oracle.
    /// ## oracle
    /// Operation representing the unknown $U(t)$ whose phase is to be
    /// estimated.
    /// ## eigenstate
    /// A register initially in a state |φ〉 such that U(t)|φ〉 = e^{i φ time}|φ〉.
    ///
    /// # Output
    /// A measurement result with probability
    /// $$
    ///     \Pr(\texttt{Zero} | \phi; \texttt{time}, \texttt{inversionAngle}) =
    ///         \cos^2([\phi - \texttt{inversionAngle}] \texttt{time} / 2).
    /// $$
    /// - For the circuit diagram see FIG. 5 on
    ///   [ Page 12 of arXiv:1304.0741 ](https://arxiv.org/pdf/1304.0741.pdf#page=12)
    operation IterativePhaseEstimationStep(
            time : Double, inversionAngle : Double,
            oracle : ((Double, Qubit[]) => () : Controlled),
            eigenstate : Qubit[]
        ) : Result
    {

        body {
            // Allocate a mutable variable to hold the result of the final
            // measurement, since we cannot return from within a using block.
            mutable result = Zero;

            // Allocate an additional qubit to use as the control register.
            using (controlRegister = Qubit[1]) {
                // Prepare the desired control state
                //  (|0〉 + e^{i θ t} |1〉) / sqrt{2}, where θ is the inversion
                // angle.
                H(controlRegister[0]);
                Rz(-time * inversionAngle, controlRegister[0]);

                // Apply U(t) controlled on this state.
                (Controlled oracle)(controlRegister, (time, eigenstate));

                // Measure the control register
                // in the X basis and record the result.
                set result = Measure([PauliX], controlRegister);

                // Before releasing the control register, we must make sure
                // to set it back to |0〉, as expected by the simulator.
                Reset(controlRegister[0]);
            }

            return result;
        }
    }

    // Equipped with this operation, we can now confirm that each phase
    // estimation iteration follows the likelihood function that we expect.
    // To make it simpler to call this check from C#, we write a small
    // operation that partially applies Exp as an oracle.
    operation ExpOracle(eigenphase : Double, time : Double, register : Qubit[]) : () {
        body {
            Rz(2.0 * eigenphase * time, register[0]);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    operation PhaseEstimationIterationCheck() : () {
        body {
            let dt = 0.1;
            let nTimes = 101;
            let nSamples = 100;
            let eigenphase = PI();
            let inversionAngle = 0.5 * PI();
            // Since |φ〉 is an eigenstate, we can reuse it between
            // successive phase iteration steps. We thus allocate a register
            // for our eigenphase now.
            using (eigenstate = Qubit[1]) {
                // We use |φ〉 = |1〉 as our eigenstate of H = φ Z.
                X(eigenstate[0]);

                // We can now make a for loop over times and samples to
                // estimate the likelihood at each time.
                for (idxTime in 0..nTimes - 1) {
                    let time = dt * ToDouble(idxTime);
                    mutable nOnesObserved = 0;

                    for (idxSample in 0..nSamples - 1) {
                        let sample = IterativePhaseEstimationStep(
                            time, inversionAngle, ExpOracle(eigenphase, _, _), eigenstate
                        );
                        if (sample == One) {
                            set nOnesObserved = nOnesObserved + 1;
                        }
                    }

                    let obs = ToDouble(nOnesObserved) / ToDouble(nSamples);
                    let mean = PowD(Sin((eigenphase - inversionAngle) * time / 2.0), 2.0);

                    Message($"Observed {obs} at {time}, expected {mean}.");
                }

                // Before releasing the eigenstate we've been working with,
                // we reset it back to |0〉 as expected by the simulator.
                X(eigenstate[0]);
            }

        }
    }

    // Having checked that the phase estimation iteration does indeed follow
    // the likelihood function we expected, we can proceed to learn the
    // phase. For this sample, we will follow the Bayesian formalism, and
    // will attempt to find the posterior distribution
    //
    //     Pr(φ | data) = Pr(data | φ) Pr(φ) / Pr(data),
    //
    // where Pr(φ) is the prior distribution over φ, where Pr(data | φ) is the
    // likelihood function that we tested in the previous step, and where
    // Pr(data) = ∫ Pr(data | φ) Pr(φ) dφ is a normalization factor.
    // For simplicity, we will take Pr(φ) = 1 over the interval [0, 1] as our
    // prior.

    // The estimate ̂φ can then be found by integrating over the posterior,
    //
    //     ̂φ ≔ ∫ φ Pr(φ | data) dφ.
    //
    // We will use an explicit grid method, in which we discretize the prior
    // and posterior at each φ, effectively replacing the integrals above
    // with the trapezoidal rule.

    // To select the experiment times {t₀, t₁, ...} that we perform our
    // phase estimation iterations at, we follow the recommendations of
    // Ferrie et al. (https://arxiv.org/abs/1110.3067) and choose
    // tₖ = (9 / 8)^k.

    // It's helpful in writing up Bayesian phase estimation with the explicit
    // grid method to first define a couple utility functions.

    /// # Summary
    /// Integrates a function f using the trapezoidal rule, given samples from
    /// that function.
    ///
    /// # Input
    /// ## xs
    /// An array of the arguments to the function at each sample.
    /// ## ys
    /// An array of the function's value at each sample.
    ///
    /// # Output
    /// An approximation of ∫_I f(x) dx, where I is the interval [x₀, xₘ],
    /// and where m is the length of `xs`.
    function Integrate(xs : Double[], ys : Double[]) : Double {
        mutable sum = 0.0;
        for (idxPoint in 0..Length(xs) - 2) {
            let trapezoidalHeight = (ys[idxPoint + 1] + ys[idxPoint]) * 0.5;
            let trapezoidalBase = xs[idxPoint + 1] - xs[idxPoint];
            set sum = sum + trapezoidalBase * trapezoidalHeight;
        }

        return sum;
    }

    /// # Summary
    /// Given two arrays, returns a new array that is the pointwise product
    /// of each of the given arrays.
    function MultiplyPointwise(left : Double[], right : Double[]) : Double[] {
        mutable product = new Double[Length(left)];
        for (idxElement in 0..Length(left) - 1) {
            set product[idxElement] = left[idxElement] * right[idxElement];
        }
        return product;
    }

    // We are now equipped to implement Bayesian inference for iterative
    // phase estimation. In principle, we could also report the variance to
    // obtain rigorous error bars, but we forego that here in the interest of
    // simplicity.

    /// # Summary
    /// Performs Bayesian phase estimation on a given oracle, using an
    /// explicit grid to estimate the posterior distribution at each step.
    ///
    /// # Input
    /// ## nGridPoints
    /// The number of points at which the posterior should be discretized.
    /// ## nMeasurements
    /// The number of measurements that should be performed.
    /// ## oracle
    /// A family of unitaries parameterized by time {U(t) | t > 0}, such that 
    /// the phase of the dynamical generator for {U(t)} is to be estimated.
    /// ## eigenstate
    /// A register initialized to a state |φ〉 such that U(t) = e^{i φ t} |φ〉
    /// for some φ to be estimated.
    ///
    /// # Output
    /// An estimate ̂φ of the unknown phase φ.
    /// - For the theoretical and algorithmic background see 
    ///   [ Page 1 of arXiv:1508.00869 ](https://arxiv.org/pdf/1508.00869.pdf#page=1)
    operation BayesianPhaseEstimation(
            nGridPoints : Int, nMeasurements : Int,
            oracle : ((Double, Qubit[]) => () : Controlled),
            eigenstate : Qubit[]
        ) : Double
    {
        body {
            // Initialize a grid for the prior and posterior discretization.
            // We'll choose the grid to be uniform.
            let dPhase = 1.0 / ToDouble(nGridPoints - 1);
            let maxTime = 100.0;

            mutable phases = new Double[nGridPoints];
            mutable prior = new Double[nGridPoints];

            for (idxGridPoint in 0..nGridPoints - 1) {
                set phases[idxGridPoint] = dPhase * ToDouble(idxGridPoint);
                set prior[idxGridPoint] = 1.0;
            }

            // We can now check that we get a prior estimate of about 0.5
            // by integrating φ over the prior defined above.
            let priorEst = Integrate(phases, MultiplyPointwise(phases, prior));
            Message($"̂φ from prior: {priorEst}. Should be approximately 0.5.");

            // Having assured ourselves that the prior is a reasonable
            // approximation to the true prior, we can now proceed to take
            // actual measurements using phase estimation iterations.
            for (idxMeasurement in 0..nMeasurements - 1) {
                // Pick an evolution time and perturbation angle at random.
                // To do so, we use the RandomReal operation from the canon,
                // asking for 16 bits of randomness.
                let time = PowD(9.0 / 8.0, ToDouble(idxMeasurement));

                // Similarly, we pick a perturbation angle to invert by.
                let inversionAngle = RandomReal(16) * 0.02;

                // Now we actually perform the measurement.
                let sample = IterativePhaseEstimationStep(
                    time, inversionAngle, oracle, eigenstate
                );

                // Next, we calculate the likelihood
                //
                //     Pr(One | φ; t) = sin²([φ - θ] t / 2)
                //
                // for the new sample, where φ is the unknown phase, θ is the
                // inversion angle applied above, and where t is the evolution
                // time. The likelihood for observing Zero is similar, with
                // cos² of the argument instead of sin².
                
                // We calculate the likelihood at each phase in our
                // approximation of the prior.

                mutable likelihood = new Double[nGridPoints];
                if (sample == One) {
                    for (idxGridPoint in 0..Length(likelihood) - 1) {
                        let arg = (phases[idxGridPoint] - inversionAngle) * time / 2.0;
                        set likelihood[idxGridPoint] = PowD(Sin(arg), 2.0);
                    }
                } else {
                    for (idxGridPoint in 0..Length(likelihood) - 1) {
                        let arg = (phases[idxGridPoint] - inversionAngle) * time / 2.0;
                        set likelihood[idxGridPoint] = PowD(Cos(arg), 2.0);
                    }
                }

                // Update the prior and renormalize, setting the new prior
                // for the next iteration of the loop.

                // In particular, recall that
                //
                //     Pr(φ | data) = Pr(data | φ) Pr(φ) / ∫ Pr(data | φ) Pr(φ) dφ.
                //
                // We can find the denominator by first calculating the
                // unnormalized posterior
                //
                //     Pr'(φ | data) ≔ Pr(data | φ) Pr(φ),
                //
                // and then insisting that the integral of the resulting
                // function is one.
                
                // Thus, we proceed to first compute the unnormalized
                // posterior using the pointwise multiplication defined above.
                let unnormalizedPosterior = MultiplyPointwise(prior, likelihood);

                // Renormalizing the posterior consists of computing the
                // integral of the unnormalized posterior, then dividing
                // through by this integral. We store the result in prior,
                // representing that the posterior forms the prior for the
                // next iteration of the for loop over measurements.
                let normalization = Integrate(phases, unnormalizedPosterior);
                for (idxGridPoint in 0..Length(prior) - 1) {
                    set prior[idxGridPoint] = unnormalizedPosterior[idxGridPoint] / normalization;
                }

                // We print out the estimate from our posterior to the
                // target machine by using its implementation of the Message
                // function.
                let posteriorEst = Integrate(phases, MultiplyPointwise(phases, prior));
                Message($"̂φ from posterior at #{idxMeasurement}: {posteriorEst}.");

            }

            // Now that we're done measuring, we report the final estimate.
            // Note that we still use the variable `prior`, since that would
            // be the prior heading into the next iteration if we kept going.
            return Integrate(phases, MultiplyPointwise(phases, prior));
        }
    }

    // To make it easier to run our new operation from C#, we provide an
    // operation that defines all of the relevant oracles for a given "true"
    // phase, and then returns the estimated phase.

    operation BayesianPhaseEstimationSample(eigenphase : Double) : Double
    {
        body
        {
            let oracle = ExpOracle(eigenphase, _, _);
            mutable est = 0.0;
            using (eigenstate = Qubit[1]) {
                X(eigenstate[0]);
                set est = BayesianPhaseEstimation(20001, 60, oracle, eigenstate);
                Reset(eigenstate[0]);
            }
            return est;
        }
    }

    //////////////////////////////////////////////////////////////////////////
    // Bayesian Phase Estimation with the Canon //////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // For comparison, we use the random walk phase estimation algorithm
    // provided with the canon. This algorithm can use additional data to
    // "unwind" the effects of outlier data, such that it may consume more
    // than the 60 measurements it is given.

    operation BayesianPhaseEstimationCanonSample(eigenphase : Double) : Double {
        body {
           let oracle = ContinuousOracle(ExpOracle(eigenphase, _, _));
           mutable est = 0.0;
           using (eigenstate = Qubit[1]) {
                X(eigenstate[0]);
                set est = RandomWalkPhaseEstimation(0.0, 1.0, 61, 100000, 0, oracle, eigenstate);
                Reset(eigenstate[0]);
            }
            return est;
        }
    }

}
