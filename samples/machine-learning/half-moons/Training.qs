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

    function DefaultSchedule(samples : Double[][]) : Int[][] {
        return [
            [0, 1, Length(samples) - 1]
        ];
    }

    // FIXME: This needs to return a GateSequence value, but that requires adapting
    //        TrainQcccSequential.
    function ClassifierStructure() : Int[][] {
        // FIXME: Change these to Pauli values, change Y to be 3.
        let (x, y, z) = (1, 2, 3);
        return [
            [4, x, 0],
            [5, z, 0],
            [6, x, 1],
            [7, z, 1],
            [0, x, 0, 1],
            [1, x, 1, 0],
            [2, z, 1],
            [3, x, 1]
        ];
    }

    operation Train(
        trainingVectors : Double[][],
        trainingLabels : Int[],
        initialParameters : Double[][]
    ) : (Double[], Double) {
        let nQubits = 2;
        let learningRate = 0.1;
        let minibatchSize = 15;
        let tolerance = 0.005;
        let nMeasurements = 10000;
        let maxEpochs = 16;
        let ppVectors = Preprocessed(trainingVectors);
        Message("Ready to train.");
        let (optimizedParameters, optimialBias) = TrainQcccSequential(
            nQubits,
            ClassifierStructure(),
            initialParameters,
            ppVectors, trainingLabels,
            DefaultSchedule(trainingVectors),
            DefaultSchedule(trainingVectors),
            learningRate, tolerance, minibatchSize,
            maxEpochs,
            nMeasurements
        );
        Message($"Training complete, found optimal parameters: {optimizedParameters}");
        return (optimizedParameters, optimialBias);
    }

    operation Validate(
        validationVectors : Double[][],
        validationLabels : Int[],
        parameters : Double[],
        bias : Double
    ) : Int {
        let nQubits = 2;
        let tolerance = 0.005;
        let nMeasurements = 10000;
        return CountValidationMisses(
            tolerance,
            nQubits,
            validationVectors,
            validationLabels,
            DefaultSchedule(validationVectors),
            ClassifierStructure(),
            parameters,
            bias,
            nMeasurements
        );
    }

}
