
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Reflection;
using static System.Math;

namespace Microsoft.Quantum.Samples
{
    using Microsoft.Quantum.MachineLearning;

    class Program
    {
        static async Task Main()
        {
            // We start by loading the training and validation data from our JSON
            // data file.
            var data = await LoadData(Path.Join(Path.GetDirectoryName(Assembly.GetEntryAssembly().Location), "data.json"));

            // We then define the classifier parameters where we want to start our
            // training iterations from. Since gradient descent is good at finding
            // local optima, it's helpful to have a variety of different starting
            // points.
            var parameterStartingPoints = new []
            {
                new [] {0.060057, 3.00522,  2.03083,  0.63527,  1.03771, 1.27881, 4.10186,  5.34396},
                new [] {0.586514, 3.371623, 0.860791, 2.92517,  1.14616, 2.99776, 2.26505,  5.62137},
                new [] {1.69704,  1.13912,  2.3595,   4.037552, 1.63698, 1.27549, 0.328671, 0.302282},
                new [] {5.21662,  6.04363,  0.224184, 1.53913,  1.64524, 4.79508, 1.49742,  1.5455}
            };

            // Next, we initialize a full state-vector simulator as our target machine.
            using var targetMachine = new QuantumSimulator();

            // Once we have the data loaded and have initialized our target machine,
            // we can then use that target machine to train a QCC classifier.
            var (optimizedParameters, optimizedBias) = await TrainHalfMoonModel.Run(
                targetMachine,
                new QArray<QArray<double>>(data.TrainingData.Features.Select(vector => new QArray<double>(vector))),
                new QArray<long>(data.TrainingData.Labels),
                new QArray<QArray<double>>(parameterStartingPoints.Select(parameterSet => new QArray<double>(parameterSet)))
            );

            // After training, we can use the validation data to test the accuracy
            // of our new classifier.
            var missRate = await ValidateHalfMoonModel.Run(
                targetMachine,
                new QArray<QArray<double>>(data.ValidationData.Features.Select(vector => new QArray<double>(vector))),
                new QArray<long>(data.ValidationData.Labels),
                optimizedParameters,
                optimizedBias
            );
            System.Console.WriteLine($"Observed {100 * missRate:F2}% misclassifications.");
        }

        class LabeledData
        {
            public List<double[]> Features  { get; set; }
            public List<long> Labels  { get; set; }
        }

        class DataSet
        {
            public LabeledData TrainingData { get; set; }
            public LabeledData ValidationData  { get; set; }
        }

        static async Task<DataSet> LoadData(string dataPath)
        {
            using var dataReader = File.OpenRead(dataPath);
            return await JsonSerializer.DeserializeAsync<DataSet>(
                dataReader
            );
        }

    }
}
