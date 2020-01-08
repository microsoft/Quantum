// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.MachineLearning;
    open Microsoft.Quantum.Math;

    function WithOffset(offset : Double, sample : Double[]) : Double[] {
        return Mapped(TimesD(offset, _), sample);
    }

    function WithProductKernel(scale : Double, sample : Double[]) : Double[] {
        return sample + [scale * Fold(TimesD, 1.0, sample)];
    }

    function Preprocessed(samples : Double[][]) : Double[][] {
        let offset = 0.75;
        let scale = 1.0;

        return Mapped(
            Compose(
                WithOffset(offset, _),
                WithProductKernel(scale, _)
            ),
            samples
        );
    }

    function DefaultSchedule(samples : Double[][]) : SamplingSchedule {
        return SamplingSchedule([
            0..Length(samples) - 1
        ]);
    }

    function ClassifierStructure() : GateSequence {
        return GateSequence([
            ControlledRotation(GateSpan(0, new Int[0]), PauliX, 4),
            ControlledRotation(GateSpan(0, new Int[0]), PauliZ, 5),
            ControlledRotation(GateSpan(1, new Int[0]), PauliX, 6),
            ControlledRotation(GateSpan(1, new Int[0]), PauliZ, 7),
            ControlledRotation(GateSpan(0, [1]), PauliX, 0),
            ControlledRotation(GateSpan(1, [0]), PauliX, 1),
            ControlledRotation(GateSpan(1, new Int[0]), PauliZ, 2),
            ControlledRotation(GateSpan(1, new Int[0]), PauliX, 3)
        ]);
    }

    operation TrainHalfMoonModel(
        trainingVectors : Double[][],
        trainingLabels : Int[],
        initialParameters : Double[][]
    ) : (Double[], Double) {
        let samples = Mapped(
            LabeledSample,
            Zip(Preprocessed(trainingVectors), trainingLabels)
        );
        Message("Ready to train.");
        let optimizedModel = TrainSequentialClassifier(
            ClassifierStructure(),
            initialParameters,
            samples,
            DefaultTrainingOptions()
                w/ LearningRate <- 0.1
                w/ MinibatchSize <- 15
                w/ Tolerance <- 0.005
                w/ NMeasurements <- 10000
                w/ MaxEpochs <- 16,
            DefaultSchedule(trainingVectors),
            DefaultSchedule(trainingVectors)
        );
        Message($"Training complete, found optimal parameters: {optimizedModel::Parameters}");
        return (optimizedModel::Parameters, optimizedModel::Bias);
    }

    operation ValidateHalfMoonModel(
        validationVectors : Double[][],
        validationLabels : Int[],
        parameters : Double[],
        bias : Double
    ) : Int {
        let samples = Mapped(
            LabeledSample,
            Zip(Preprocessed(validationVectors), validationLabels)
        );
        let nQubits = 2;
        let tolerance = 0.005;
        let nMeasurements = 10000;
        let results = ValidateModel(
            ClassifierStructure(),
            SequentialModel(parameters, bias),
            samples,
            tolerance,
            nMeasurements,
            DefaultSchedule(validationVectors)
        );
        return results::NMisclassifications;
    }

}
