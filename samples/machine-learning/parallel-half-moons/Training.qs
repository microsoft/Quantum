// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.MachineLearning;
    open Microsoft.Quantum.Math;

    function WithProductKernel(scale : Double, sample : Double[]) : Double[] {
        return sample + [scale * Fold(TimesD, 1.0, sample)];
    }

    function Preprocessed(samples : Double[][]) : Double[][] {
        let scale = 1.0;

        return Mapped(
            WithProductKernel(scale, _),
            samples
        );
    }

    function DefaultSchedule(samples : Double[][]) : SamplingSchedule {
        return SamplingSchedule([
            0..Length(samples) - 1
        ]);
    }

    function ClassifierStructure() : ControlledRotation[] {
        return [
            ControlledRotation((0, new Int[0]), PauliX, 4),
            ControlledRotation((0, new Int[0]), PauliZ, 5),
            ControlledRotation((1, new Int[0]), PauliX, 6),
            ControlledRotation((1, new Int[0]), PauliZ, 7),
            ControlledRotation((0, [1]), PauliX, 0),
            ControlledRotation((1, [0]), PauliX, 1),
            ControlledRotation((1, new Int[0]), PauliZ, 2),
            ControlledRotation((1, new Int[0]), PauliX, 3)
        ];
    }

    operation TrainHalfMoonModelAtStartPoint(
        trainingVectors : Double[][],
        trainingLabels : Int[],
        startPoint : Double[]
    ) : (Double[], Double) {
        let samples = Mapped(
            LabeledSample,
            Zip(Preprocessed(trainingVectors), trainingLabels)
        );
        let options = DefaultTrainingOptions()
                w/ LearningRate <- 0.1
                w/ MinibatchSize <- 15
                w/ Tolerance <- 0.005
                w/ NMeasurements <- 10000
                w/ MaxEpochs <- 16
                w/ VerboseMessage <- Message;
        Message("Ready to train.");
        // Train at the given start point, and get back an
        // optimized model.
        let optimizedModel = TrainSequentialClassifierAtModel(
            SequentialModel(ClassifierStructure(), startPoint, 0.0),
            samples,
            options,
            DefaultSchedule(trainingVectors),
            1
        );

        
        let probabilities = EstimateClassificationProbabilities(
            options::Tolerance,
            optimizedModel,
            Sampled(validationSchedule, features),
            options::NMeasurements
        );
        // Find the best bias for the new classification parameters.
        let localBias = _UpdatedBias(
            Zip(probabilities, Sampled(validationSchedule, labels)),
            0.0,
            options::Tolerance
        );
        let localPL = InferredLabels(localBias, probabilities);
        let localMisses = NMisclassifications(localPL, Sampled(validationSchedule, labels));
        if (bestValidation > localMisses) {
            set bestValidation = localMisses;
            set bestSoFar = proposedUpdate;
        }
        Message($"Training complete, found optimal parameters: {optimizedModel::Parameters}");
        return (optimizedModel::Parameters, optimizedModel::Bias);
    }

    operation ValidateHalfMoonModel(
        validationVectors : Double[][],
        validationLabels : Int[],
        parameters : Double[],
        bias : Double
    ) : Double {
        let samples = Mapped(
            LabeledSample,
            Zip(Preprocessed(validationVectors), validationLabels)
        );
        let tolerance = 0.005;
        let nMeasurements = 10000;
        let results = ValidateSequentialClassifier(
            SequentialModel(ClassifierStructure(), parameters, bias),
            samples,
            tolerance,
            nMeasurements,
            DefaultSchedule(validationVectors)
        );
        return IntAsDouble(results::NMisclassifications) / IntAsDouble(Length(samples));
    }

}
