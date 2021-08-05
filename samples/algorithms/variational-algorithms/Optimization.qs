// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Random;

    /// # Summary
    /// Options for use with optimizing objectives via the simulntaneous
    /// perturbative stochastic approximation (SPSA) algorithm.
    ///
    /// # Named Items
    /// ## StepScale
    /// The coefficient by which steps along gradient vectors should be scaled.
    /// ## StepPower
    /// The power to which the iteration number should be raised when computing
    /// how far to step along the gradient vector.
    /// ## StepOffset
    /// A number to be added to the number of iterations when computing
    /// how far to step along the gradient vector.
    /// ## SearchScale
    /// The coefficient by which searches should be scaled when estimating
    /// gradient vectors.
    /// ## SearchPower
    /// The power to which the iteration number should be raised when computing
    /// how far to search in order to estimate gradient vectors.
    /// ## NIterations
    /// The number of iterations of SPSA to run before stopping.
    /// ## MaximumSetback
    /// Whether the maximum setback rule is enabled (requiring an additional
    /// objective evaluation at each iteration), and if so, the maximum
    /// allowed increase in objective values at each iteration.
    /// ## VerboseMessage
    /// A function to be called to report verbose information about optimization
    /// progress.
    newtype SpsaOptions = (
         StepScale: Double,
         StepPower: Double,
         StepOffset: Int,
         SearchScale: Double,
         SearchPower: Double,
         NIterations: Int,
         MaximumSetback: (Bool, Double),
         VerboseMessage: String -> Unit
    );

    /// # Summary
    /// Returns a default set of options for use with SPSA optimization.
    function DefaultSpsaOptions() : SpsaOptions {
        return Default<SpsaOptions>()
            w/ SearchScale <- 0.1
            w/ SearchPower <- 0.101
            w/ StepScale <- 1.0
            w/ StepPower <- 0.602
            w/ StepOffset <- 0
            w/ MaximumSetback <- (false, 0.1)
            w/ NIterations <- 30
            w/ VerboseMessage <- Message;
    }

    /// # Summary
    /// Given an operation that evaluates an objective at a given point,
    /// attempts to find the minimum value of the objective by using the
    /// simulntaneous perturbative stochastic approximation (SPSA).
    ///
    /// # Input
    /// ## oracle
    /// An operation that evaluates the objective function at a given point.
    /// ## startingPoint
    /// An initial guess to be used in optimizing the objective function
    /// provided.
    /// ## options
    /// Options used to control the optimization algorithm.
    ///
    /// # Output
    /// The coordinates and final objective value found by the SPSA algorithm.
    operation FindMinimumWithSpsa(oracle : (Double[] => Double), startingPoint : Double[], options : SpsaOptions) : (Double[], Double) {
        let nParameters = Length(startingPoint);
        let deltaDist = DiscreteUniformDistribution(0, 1);
        let drawDelta = Delayed(MaybeChooseElement, ([-1.0, 1.0], deltaDist));

        mutable currentPoint = startingPoint;

        // Depending on what options are enabled, we may reject certain
        // updates, so we keep a counter as to how many iterations have been
        // accepted.
        mutable nAcceptedUpdates = 0;
        mutable lastObjective = 0.0;

        // The SPSA algorithm proceeds by estimating the gradient of the
        // objective, projected onto a random vector Δ of ±1 elements. At each
        // iteration, the step size used to evaluate the gradient and the
        // step taken along the estimated gradient decay to zero,
        // such that the algorithm converges to a local optimum by follow
        // a directed random walk that is biased by gradients of the objective.
        for idxStep in 1..options::NIterations {
            options::VerboseMessage($"Iteration {idxStep}:");

            // Following this strategy, we'll start by using the options
            // passed into this operation to set αₖ, the amount that we look
            // along Δ when using the midpoint formula to evaluate the gradient
            // of the objective function 𝑜, and βₖ, the amount that we step
            // along the gradient to find the next evaluation point.
            let searchSize = options::SearchScale / PowD(IntAsDouble(1 + nAcceptedUpdates), options::SearchPower);
            let stepSize = options::StepScale / PowD(IntAsDouble(1 + nAcceptedUpdates + options::StepOffset), options::StepPower);

            // We next draw Δ itself, then use it to find 𝑥ₖ + αₖ Δ and
            // 𝑥ₖ − αₖ Δ.
            let delta = Mapped(Snd, DrawMany(drawDelta, nParameters, ()));
            let search = Mapped(TimesD(searchSize, _), delta);
            let fwd = Mapped(PlusD, Zipped(currentPoint, search));
            let bwd = Mapped(PlusD, Zipped(currentPoint, Mapped(TimesD(-1.0, _), search)));

            // We then evaluate 𝑜 at each of these two points to find the
            // negative gradient 𝑔ₖ = 𝑜(𝑥ₖ − αₖ Δ) − 𝑜(𝑥ₖ + αₖ Δ).
            let valueAtForward = oracle(fwd);
            let valueAtBackward = oracle(bwd);
            let negGradient = (oracle(bwd) - oracle(fwd)) / (2.0 * searchSize);
            options::VerboseMessage($"\tobj({fwd}) = {valueAtForward}\n\tobj({bwd}) = {valueAtBackward}");

            // We can step along 𝑔ₖ to find 𝑥ₖ₊₁. Depending on whether options
            // such as the maximum setback rule are enabled, we may reject
            // the update. Either way, we report out to the caller at this
            // point.
            let step = Mapped(TimesD(negGradient * stepSize, _), delta);
            let proposal = Mapped(PlusD, Zipped(step, currentPoint));
            if Fst(options::MaximumSetback) {
                // Is this our first update? If so, accept and set the
                // lastObjective.
                if nAcceptedUpdates == 0 {
                    options::VerboseMessage($"\tFirst update; accepting.");
                    set lastObjective = oracle(proposal);
                    set nAcceptedUpdates += 1;
                    set currentPoint = proposal;
                } else {
                    // How much did our objective get worse (increase) by?
                    let thisObjective = oracle(proposal);
                    if thisObjective - lastObjective <= Snd(options::MaximumSetback) {
                        options::VerboseMessage($"\tProposed update gave objective of {thisObjective}, which is within maximum allowable setback of previous objective {lastObjective}; accepting.");
                        // Within the limit, so we're good.
                        set lastObjective = thisObjective;
                        set nAcceptedUpdates += 1;
                        set currentPoint = proposal;
                    } else {
                        options::VerboseMessage($"\tProposed update gave objective of {thisObjective}, which exceeds maximum allowable setback from previous objective {lastObjective}; rejecting.");
                    }
                }
            } else {
                // No maximum setback rule, so always accept the proposed
                // update.
                set nAcceptedUpdates += 1;
                set currentPoint = proposal;
            }

        }

        return (currentPoint, oracle(currentPoint));
    }

}
