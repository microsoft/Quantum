// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.PhaseEstimation {
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;

    @EntryPoint()
    operation RunProgram(eigenphase : Double, nGridPoints : Int, nMeasurements : Int) : Double {
        let oracle = EvolveForTime(eigenphase, _, _);

        let (phases, prior, priorEst) = SetUpEstimation(nGridPoints);
        let (outPhases, outPrior) = EstimatePhase(nGridPoints, nMeasurements, oracle, phases, prior, priorEst);
        return Integrated(outPhases, PointwiseProduct(outPhases, outPrior));
    }

    operation ApplyIterativePhaseEstimationStep(time : Double, inversionAngle : Double, oracle : ((Double, Qubit[]) => Unit is Ctl), eigenstate : Qubit[]) : Result {

        // Allocate a mutable variable to hold the result of the final
        // measurement, since we cannot return from within a using block.
        mutable result = Zero;

        // Allocate an additional qubit to use as the control register.
        use controlQubit = Qubit();

        // Prepare the desired control state
        //  (|0〉 + e^{i θ t} |1〉) / sqrt{2}, where θ is the inversion
        // angle.
        H(controlQubit);
        Rz(-time * inversionAngle, controlQubit);

        // Apply U(t) controlled on this state.
        Controlled oracle([controlQubit], (time, eigenstate));

        // Measure the control register
        // in the X basis and record the result.
        // Before releasing the control register, we must make sure
        // to set it back to |0〉, as expected by the simulator.
        return MResetX(controlQubit);
    }

    operation EvolveForTime(eigenphase : Double, time : Double, register : Qubit[]) : Unit is Adj + Ctl {
        Rz((2.0 * eigenphase) * time, Head(register));
    }

    function Integrated(xs : Double[], ys : Double[]) : Double {
        mutable sum = 0.0;

        for idxPoint in 0 .. Length(xs) - 2 {
            let trapezoidalHeight = (ys[idxPoint + 1] + ys[idxPoint]) * 0.5;
            let trapezoidalBase = xs[idxPoint + 1] - xs[idxPoint];
            set sum += trapezoidalBase * trapezoidalHeight;
        }

        return sum;
    }

    function PointwiseProduct(left : Double[], right : Double[]) : Double[] {
        mutable product = new Double[Length(left)];

        for idxElement in IndexRange(left) {
            set product w/= idxElement <- left[idxElement] * right[idxElement];
        }

        return product;
    }

    function SetUpEstimation(nGridPoints : Int) : (Double[], Double[], Double) {
        let dPhase = 1.0 / IntAsDouble(nGridPoints - 1);
        mutable phases = new Double[nGridPoints];
        mutable prior = new Double[nGridPoints];

        for idxGridPoint in 0 .. nGridPoints - 1 {
            set phases w/= idxGridPoint <- dPhase * IntAsDouble(idxGridPoint);
            set prior w/= idxGridPoint <- 1.0;
        }

        // We can now check that we get a prior estimate of about 0.5
        // by integrating φ over the prior defined above.
        let priorEst = Integrated(phases, PointwiseProduct(phases, prior));

        return (phases, prior, priorEst);
    }

    operation EstimatePhase(nGridPoints : Int, nMeasurements : Int, oracle : ((Double, Qubit[]) => Unit is Ctl), inPhases : Double[], inPrior : Double[], priorEst : Double) : (Double[], Double[]) {

        // Initialize a grid for the prior and posterior discretization.
        // We'll choose the grid to be uniform.
        mutable phases = inPhases;
        mutable prior = inPrior;

        use eigenstate = Qubit[1];
        X(eigenstate[0]);

        // Having assured ourselves that the prior is a reasonable
        // approximation to the true prior, we can now proceed to take
        // actual measurements using phase estimation iterations.
        for idxMeasurement in 0 .. nMeasurements - 1 {

            // Pick an evolution time and perturbation angle at random.
            // To do so, we use the RandomReal operation from the canon,
            // asking for 16 bits of randomness.
            let time = PowD(9.0 / 8.0, IntAsDouble(idxMeasurement));

            // Similarly, we pick a perturbation angle to invert by.
            let inversionAngle = DrawRandomDouble(0.0, 0.02);

            // Now we actually perform the measurement.
            let sample = ApplyIterativePhaseEstimationStep(time, inversionAngle, oracle, eigenstate);

            // Next, we calculate the likelihood

            //     Pr(One | φ; t) = sin²([φ - θ] t / 2)

            // for the new sample, where φ is the unknown phase, θ is the
            // inversion angle applied above, and where t is the evolution
            // time. The likelihood for observing Zero is similar, with
            // cos² of the argument instead of sin².

            // We calculate the likelihood at each phase in our
            // approximation of the prior.
            mutable likelihood = new Double[nGridPoints];

            if (sample == One) {
                for idxGridPoint in IndexRange(likelihood) {
                    let arg = ((phases[idxGridPoint] - inversionAngle) * time) / 2.0;
                    set likelihood w/= idxGridPoint <- PowD(Sin(arg), 2.0);
                }
            } else {
                for idxGridPoint in IndexRange(likelihood) {
                    let arg = ((phases[idxGridPoint] - inversionAngle) * time) / 2.0;
                    set likelihood w/= idxGridPoint <- PowD(Cos(arg), 2.0);
                }
            }

            // Update the prior and renormalize, setting the new prior
            // for the next iteration of the loop.

            // In particular, recall that

            //     Pr(φ | data) = Pr(data | φ) Pr(φ) / ∫ Pr(data | φ) Pr(φ) dφ.

            // We can find the denominator by first calculating the
            // unnormalized posterior

            //     Pr'(φ | data) ≔ Pr(data | φ) Pr(φ),

            // and then insisting that the integral of the resulting
            // function is one.

            // Thus, we proceed to first compute the unnormalized
            // posterior using the pointwise multiplication defined above.
            let unnormalizedPosterior = PointwiseProduct(prior, likelihood);

            // Renormalizing the posterior consists of computing the
            // integral of the unnormalized posterior, then dividing
            // through by this integral. We store the result in prior,
            // representing that the posterior forms the prior for the
            // next iteration of the for loop over measurements.
            let normalization = Integrated(phases, unnormalizedPosterior);

            for idxGridPoint in IndexRange(prior) {
                set prior w/= idxGridPoint <- unnormalizedPosterior[idxGridPoint] / normalization;
            }
        }

        ResetAll(eigenstate);

        // Now that we're done measuring, we report the final estimate.
        // Note that we still use the variable `prior`, since that would
        // be the prior heading into the next iteration if we kept going.
        return (phases, prior);
    }

}


