// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

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

    newtype SmcApproximation = (
        Locations: Double[][],
        Weights: Double[]
    );

    newtype SmcOptions = (
        ResampleThreshold: Double,
        NormThreshold: Double,
        ResampleA: Double,
        ResampleH: Double
    );

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

    function EffectiveSampleSize(dist : SmcApproximation) : Double {
        return 1.0 / Fold(PlusD, 0.0, Mapped(Squared, dist::Weights));
    }

    operation DrawParticle(dist : SmcApproximation) : Double[] {
        return dist::Locations[DrawCategorical(dist::Weights)];
    }

    function TimesScalar1D(scalar : Double, vec : Double[]) : Double[] {
        return Mapped(TimesD(scalar, _), vec);
    }

    function VectorPlusD(left : Double[], right : Double[]) : Double[] {
        return Mapped(PlusD, Zipped(left, right));
    }

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

    function OuterProduct(left : Double[], right : Double[]) : Double[][] {
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

    operation LWResampled<'TOutcome, 'TExperiment>(
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
            } else {
                // Message($"Rejecting particle at {newParticle};\nparticle {particle}\nnormal {normalVariate}\nshifted {shift}\na {aPart}\nh {hPart}.");
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
            return LWResampled(options::ResampleA, options::ResampleH, updated, model);
        } else {
            return updated;
        }
    }

}
