// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// This file contains an implementation of the sequential Monte Carlo algorithm,
// sometimes also known as the particle filtering algorithm. Effectively, this
// algorithm can be used to perform Bayesian inference online during an
// experiment. By implementing SMC in Q#, we allow for statistical inference
// to be run without returning control flow to the host program, enabling
// online experiment design to be carried out efficiently.
//
// For more details, see the discussion of SMC in
// https://arxiv.org/abs/1610.00336.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Synthesis;

    /// # Summary
    /// An approximation of a probability distribution as a weighted sum
    /// of delta-distributions, known as particles.
    ///
    /// # Description
    /// Given a probability distribution $\Pr(\vec{x})$, values of this type
    /// represent the approximation
    /// $$
    ///     \Pr(\vec{x}) \approx \sum_i w_i \delta(\vec{x} - \vec{x}_i),
    /// $$
    /// where $\{w_i\}$ are given by `::Weights` and where $\{\vec{x}_i\}$ are
    /// given by `::Locations`.
    ///
    /// For a value `dist` of this user-defined type, each
    /// element of the expression `Zipped(dist::Weights, dist::Locations)` is
    /// called a _particle_, such that this approximation is sometimes called
    /// the _particle filter approximation_. Alternatively, this approximation
    /// may be called the _sequential Monte Carlo_ approximation.
    ///
    /// # Named Items
    /// ## Locations
    /// An array of the locations of each particle.
    /// ## Weights
    /// The weights of each particle. By construction, each weight must be
    /// non-negative, and the sum of all weights must be 1.0.
    newtype SmcApproximation = (
        Locations: Double[][],
        Weights: Double[]
    );

    /// # Summary
    /// Options for controlling sequential Monte Carlo updates.
    ///
    /// # Named Items
    /// ## ResampleThreshold
    /// The participation ratio (that is, the effective sample size of an
    /// approximation divided by the total number of particles) below which
    /// a resampling step is added to recover numerical stability.
    /// ## NormThreshold
    /// A value of the vector 1-norm below which the SMC approximation is
    /// considered to have failed. In particular, when updating, if the vector
    /// of unnormalized weights is observed to have 1-norm less than the norm
    /// threshold, then an error will be raised instead of renormalizing weights.
    /// ## ResampleA
    /// The $a$ parameter to the Liu–West resampling algorithm, controlling
    /// how much of the original (non-resampled distribution) is used. When
    /// this named item is 1.0, the Liu–West resampling algorithm coincides
    /// with the bootstrap filter.
    /// ## ResampleH
    /// The $h$ parameter to the Liu–West resampling algorithm, controlling
    /// how much of the normal approximation to the original distribution is
    /// used. When this named item is 1.0, the Liu–West resampling algorithm
    /// coincides with a normal approximation to the posterior distribution.
    ///
    /// # Remarks
    /// The $a$ and $h$ parameters to the Liu–West algorithm can be
    /// independently controlled in these options, but posterior variances are
    /// only preserved when $a^2 + h^2 = 1$. Values such that $a^2 + h^2 > 1$
    /// overestimate the variance while values such that $a^2 + h^2 < 1$
    /// underestimate posterior variances. Intentionally overestimating the
    /// variance can help recover numerical stability for multi-modal
    /// distributions, but is generally discouraged.
    newtype SmcOptions = (
        ResampleThreshold: Double,
        NormThreshold: Double,
        ResampleA: Double,
        ResampleH: Double
    );

    /// # Summary
    /// Returns a default set of options for using sequential Monte Carlo.
    ///
    /// # Remarks
    /// The options returned by this function are suitable for a wide range
    /// of applications, but depending on whether your likelihood function is
    /// multi-modal or strongly peaked, you may need to modify these options
    /// accordingly.
    ///
    /// For more details, see:
    /// - https://arxiv.org/abs/1207.1655
    /// - https://arxiv.org/abs/1610.00336
    function DefaultSmcOptions() : SmcOptions {
        return SmcOptions(
            0.5,
            1e-12,
            0.98,
            Sqrt(1.0 - 0.98^2.0)
        );
    }

    internal function Squared(x : Double) : Double {
        return x * x;
    }

    /// # Summary
    /// Returns the effective sample size of a given sequential Monte Carlo
    /// approximation, representing how many particles contribute to the
    /// approximation in practice.
    ///
    /// # Remarks
    /// The effective sample size of a distribution with weights $\{w_i\}$ is
    /// defined as
    /// $$
    ///     n_{\text{ess}} = \frac{1}{\sum_i w_i^2}.
    /// $$
    /// When the effective sample size is the same as the number of particles,
    /// each particle is contributing equally to estimates drawn from the
    /// approximation.
    function EffectiveSampleSize(dist : SmcApproximation) : Double {
        return 1.0 / Fold(PlusD, 0.0, Mapped(Squared, dist::Weights));
    }

    /// # Summary
    /// Returns a sample drawn at random from a sequential Monte Carlo
    /// approximation.
    operation DrawParticle(dist : SmcApproximation) : Double[] {
        return dist::Locations[DrawCategorical(dist::Weights)];
    }

    internal function TimesScalar1D(scalar : Double, vec : Double[]) : Double[] {
        return Mapped(TimesD(scalar, _), vec);
    }

    internal function VectorPlusD(left : Double[], right : Double[]) : Double[] {
        return Mapped(PlusD, Zipped(left, right));
    }

    /// # Summary
    /// Returns the mean of a distribution as represented by a sequential Monte
    /// Carlo approximation.
    ///
    /// # Description
    /// Given an approximation $\sum_i w_i \delta(\vec{x} - \vec{x}_i)$, returns
    /// the mean $\mathbb{E}[\vec{x}] = \sum_i w_i \vec{x}_i$.
    function Mean(dist : SmcApproximation) : Double[] {
        let nModelParams = Length(dist::Locations[0]);
        let rescaled = Mapped(
            // Rescale each vector by a weight.
            TimesScalar1D,
            Zipped(dist::Weights, dist::Locations)
        );
        let init = ConstantArray(nModelParams, 0.0);
        return Fold(
            VectorPlusD,
            init,
            rescaled
        );
    }

    internal function OuterProduct(left : Double[], right : Double[]) : Double[][] {
        mutable result = ConstantArray(Length(left), ConstantArray(Length(right), 0.0));
        for idxLeft in 0..Length(left) - 1 {
            for idxRight in 0..Length(right) - 1 {
                set result w/= idxLeft <- result[idxLeft] w/ idxRight <- left[idxLeft] * right[idxRight];
            }
        }
        return result;
    }

    // NB: This is not the most numerically stable implementation, but is
    //     chosen for brevity in this sample. In practice, something like
    //     Welford's algorithm will provide a more stable implementation of the
    //     covariance.
    /// # Summary
    /// Returns the covariance of a distribution as represented by a sequential Monte
    /// Carlo approximation.
    ///
    /// # Description
    /// Given an approximation $\sum_i w_i \delta(\vec{x} - \vec{x}_i)$, returns
    /// the covariance matrix
    /// $$
    ///     \mathbb{V}[\vec{x}] = \mathbb{E}[\vec{x} \vec{x}^{\mathrm{T}}] - \mathbb{E}[\vec{x}]\mathbb{E}[\vec{x}^\mathrm{T}].
    /// $$
    function Cov(dist : SmcApproximation) : Double[][] {
        let nModelParams = Length(dist::Locations[0]);
        mutable result = ConstantArray(nModelParams, ConstantArray(nModelParams, 0.0));
        let mean = Mean(dist);
        for (w, loc) in Zipped(dist::Weights, dist::Locations) {
            let op = OuterProduct(loc, loc);
            set result = Elementwise2(PlusD)(result, TimesScalarD(w, op));
        }
        return Elementwise2(MinusD)(result, OuterProduct(mean, mean));
    }

    /// # Summary
    /// Uses the Liu–West algorithm to resample a sequential Monte Carlo
    /// approximation to a posterior distribution.
    operation Resample<'TOutcome, 'TExperiment>(
        a : Double, h : Double,
        dist : SmcApproximation,
        model : (
            (('TOutcome, Double[], 'TExperiment) -> Double),
            (Double[] -> Bool)
        )
    )
    : SmcApproximation {
        let nParticles = Length(dist::Weights);
        let nModelParams = Length(dist::Locations[0]);
        mutable newLocations = EmptyArray<Double[]>();

        // The Liu–West resampling algorithm consists of mixing 𝑎 of
        // a bootstrapped distribution with ℎ of a normal distribution with the
        // same mean and variance.
        // As a result, excluding boundary conditions, the LW algorithm is
        // guaranteed to preserve mean and variance in expectation over all
        // random choices made during the algorithm, and assuming that all
        // models are valid.

        let mean = Mean(dist);
        let shift = Mapped(TimesD(1.0 - a, _), mean);
        let cov = Cov(dist);
        let sqrtCov = TimesScalarD(h, Sqrtm(cov));

        repeat {
            let particle = DrawParticle(dist);
            let normalVariate = MatrixVectorTimesD(
                sqrtCov, DrawMany((StandardNormalDistribution())::Sample, nModelParams, ())
            );
            let aPart = Mapped(TimesD(a, _), particle);
            let hPart = Mapped(TimesD(h, _), normalVariate);
            let newParticle = VectorPlusD(
                aPart,
                VectorPlusD(shift, hPart)
            );
            if IsModelValid(model)(newParticle) {
                set newLocations += [newParticle];
            }
        }
        until Length(newLocations) == nParticles;

        let updated = SmcApproximation(
            newLocations,
            ConstantArray(nParticles, 1.0 / IntAsDouble(nParticles))
        );
        return updated;
    }

    function Likelihood<'TOutcome, 'TExperiment>(
        model : (
            (('TOutcome, Double[], 'TExperiment) -> Double),
            (Double[] -> Bool)
        )
    )
    : (('TOutcome, Double[], 'TExperiment) -> Double) 
    {
        let (likeihood, isValid) = model;
        return likeihood;
    }

    function IsModelValid<'TOutcome, 'TExperiment>(
        model : (
            (('TOutcome, Double[], 'TExperiment) -> Double),
            (Double[] -> Bool)
        )
    )
    : (Double[] -> Bool) 
    {
        let (likeihood, isValid) = model;
        return isValid;
    }

    /// # Summary
    /// Given a sequential Monte Carlo approximation to a prior distribution,
    /// updates it to include the effect of a new datum, returning an
    /// approximation of the new posterior distribution.
    ///
    /// # Remarks
    /// Updating a sequential Monte Carlo approximation may require making
    /// random choices in resampling steps, such that this is an operation
    /// rather than a function, even though distribution updates are formally
    /// deterministic.
    operation Update<'TOutcome, 'TExperiment>(
        dist : SmcApproximation,
        datum : 'TOutcome, experiment : 'TExperiment,
        model : (
            (('TOutcome, Double[], 'TExperiment) -> Double),
            (Double[] -> Bool)
        ),
        options : SmcOptions
    )
    : SmcApproximation {
        // Do the SMC update on without any resampling first.
        mutable unnormalizedWeights = dist::Weights;
        for (idx, (weight, location)) in Enumerated(Zipped(dist::Weights, dist::Locations)) {
            set unnormalizedWeights w/= idx <- Likelihood(model)(datum, location, experiment) * weight;
        }
        let norm = PNorm(1.0, unnormalizedWeights);
        if norm <= options::NormThreshold {
            fail $"All weights were approximately zero; got 1-norm {norm}.";
        }
        let updated = SmcApproximation(
            dist::Locations,
            Mapped(DividedByD(_, norm), unnormalizedWeights)
        );

        if EffectiveSampleSize(updated) / IntAsDouble(Length(dist::Weights)) <= options::ResampleThreshold {
            Message("About to resample...");
            return Resample(options::ResampleA, options::ResampleH, updated, model);
        } else {
            return updated;
        }
    }

}
