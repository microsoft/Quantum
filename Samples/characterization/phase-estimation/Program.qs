namespace PhaseEstimationSample {

    open Microsoft.Quantum.Samples.PhaseEstimation;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;


    operation Program () : Unit {
        
        // We pick an arbitrary value for the eigenphase to be
        // estimated. Note that we have assumed in the Q# operations that
        // the prior for the phase φ is supported only on the interval
        // [0, 1], so you might get inconsistent answers if you violate
        // that constraint. Try it out!
        let eigenphase = 0.344;

        // We run the PhaseEstimationIteration(). That operation
        // checks that the iterative phase estimation step has the right
        // likelihood function.
        Message("Phase Estimation Likelihood Check:");
        PhaseEstimationIterationCheck();

        // We run the BayesianPhaseEstiamtionSample operation
        // defined in Q#. This operation estimates the phase φ using an
        // explicit grid approximation to the Bayesian posterior.
        Message("Bayesian Phase Estimation w/ Explicit Grid:");
        let est = BayesianPhaseEstimationSample(eigenphase);
        Message($"Expected {eigenphase}, estimated {est}.");
    }
}
