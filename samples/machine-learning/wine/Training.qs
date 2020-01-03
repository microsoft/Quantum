// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.MachineLearning;
    open Microsoft.Quantum.MachineLearning.Datasets as Datasets;
    open Microsoft.Quantum.Math;

    function WithOffset(offset : Double, sample : LabeledSample) : LabeledSample {
        return sample
            w/ Features <- Mapped(TimesD(offset, _), sample::Features);
    }

    function Preprocessed(samples : LabeledSample[]) : LabeledSample[] {
        let offset = 0.80;

        return Mapped(
            WithOffset(offset, _),
            samples
        );
    }

    function DefaultSchedule(samples : LabeledSample[]) : SamplingSchedule {
        return SamplingSchedule([
            0..Length(samples) - 1
        ]);
    }

    // FIXME: This needs to return a GateSequence value, but that requires adapting
    //        TrainQcccSequential.
    function ClassifierStructure() : GateSequence {
        return CombinedGateSequence([
            LocalRotationsLayer(4, PauliZ),
            LocalRotationsLayer(4, PauliX),
            CyclicEntanglingLayer(4, PauliX, 1),
            PartialRotationsLayer([3], PauliX)
        ]);
    }

    operation SampleSingleParameter() : Double {
        return PI() * (RandomReal(16) - 1.0);
    }

    operation SampleParametersForSequence(structure : GateSequence) : Double[] {
        return ForEach(SampleSingleParameter, ConstantArray(Length(structure!), ()));
    }

    operation SampleInitialParameters(nInitialParameterSets : Int, structure : GateSequence) : Double[][] {
        return ForEach(SampleParametersForSequence, ConstantArray(nInitialParameterSets, structure));
    }

    operation TrainWineModel() : (Double[], Double) {
        // Get the first 143 samples to use as training data.
        let samples = Preprocessed((Datasets.WineData())[...142]);
        let structure = ClassifierStructure();
        // Sample a random set of parameters.
        let initialParameters = SampleInitialParameters(16, structure);

        Message("Ready to train.");
        let optimizedModel = TrainSequentialClassifier(
            structure,
            initialParameters,
            samples,
            DefaultTrainingOptions()
                w/ LearningRate <- 0.4
                w/ MinibatchSize <- 2
                w/ Tolerance <- 0.01
                w/ NMeasurements <- 10000
                w/ MaxEpochs <- 16,
            DefaultSchedule(samples),
            DefaultSchedule(samples)
        );
        Message($"Training complete, found optimal parameters: {optimizedModel::Parameters}");
        return (optimizedModel::Parameters, optimizedModel::Bias);
    }

    operation ValidateWineModel(
        parameters : Double[],
        bias : Double
    ) : Int {
        // Get the remaining samples to use as validation data.
        let samples = Preprocessed((Datasets.WineData())[143...]);
        let nQubits = 2;
        let tolerance = 0.005;
        let nMeasurements = 10000;
        let results = ValidateModel(
            ClassifierStructure(),
            SequentialModel(parameters, bias),
            samples,
            tolerance,
            nMeasurements,
            DefaultSchedule(samples)
        );
        return results::NMisclassifications;
    }

}
