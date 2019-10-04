import qsharp
from Microsoft.Quantum.Samples.PhaseEstimation import (
    PhaseEstimationIterationCheck, BayesianPhaseEstimationSample
)

# We pick an arbitrary value for the eigenphase to be
# estimated. Note that we have assumed in the Q# operations that
# the prior for the phase φ is supported only on the interval
# [0, 1], so you might get inconsistent answers if you violate
# that constraint. Try it out!
eigenphase = 0.344

# We run the PhaseEstimationIteration
# operation defined in the associated Q# file. That operation
# checks that the iterative phase estimation step has the right
# likelihood function.
print("Phase Estimation Likelihood Check:")
PhaseEstimationIterationCheck.simulate()

# Next, we run the BayesianPhaseEstiamtionSample operation
# defined in Q#. This operation estimates the phase φ using an
# explicit grid approximation to the Bayesian posterior.

print("Bayesian Phase Estimation w/ Explicit Grid:")
est = BayesianPhaseEstimationSample.simulate(eigenphase=eigenphase)
print(f"Expected {eigenphase}, estimated {est}.")
