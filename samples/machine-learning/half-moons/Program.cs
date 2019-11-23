
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
using static System.Math;

namespace Microsoft.Quantum.Samples
{
    using Microsoft.Quantum.MachineLearning;
    using Microsoft.Quantum.MachineLearning.Interop;

    class Program
    {
        static async Task Main()
        {
            var data = await LoadData("data.json");
            var paramSource = new double[][]
            {
                new double[] {0.060057, 3.00522, 2.03083, 0.63527, 1.03771, 1.27881, 4.10186,   5.34396},
                new double[] {0.586514, 3.371623, 0.860791, 2.92517,   1.14616, 2.99776, 2.26505, 5.62137},
                new double[] {1.69704,   1.13912, 2.3595, 4.037552, 1.63698, 1.27549, 0.328671, 0.302282},
                new double[] { 5.21662, 6.04363, 0.224184, 1.53913, 1.64524, 4.79508, 1.49742, 1.5455}
            };
            using var targetMachine = new QuantumSimulator(false, 12345678);
            var (optimizedParameters, optimizedBias) = await TrainHalfMoonModel.Run(
                targetMachine,
                new QArray<QArray<double>>(data.TrainingData.Features.Select(vector => new QArray<double>(vector))),
                new QArray<long>(data.TrainingData.Labels),
                new QArray<QArray<double>>(paramSource.Select(parameterSet => new QArray<double>(parameterSet)))
            );

            //NOW DO SOME TESTING
            var testMisses = await ValidateHalfMoonModel.Run(
                targetMachine,
                new QArray<QArray<double>>(data.ValidationData.Features.Select(vector => new QArray<double>(vector))),
                new QArray<long>(data.ValidationData.Labels),
                optimizedParameters,
                optimizedBias
            );
            System.Console.WriteLine($"Observed {testMisses} misclassifications out of {data.ValidationData.Labels.Count} validation samples.");
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

        static async Task<DataSet> LoadData(string dataPath, double offset = 0.0, double filler = 1.0)
        {
            using var dataReader = File.OpenRead(dataPath);
            return await JsonSerializer.DeserializeAsync<DataSet>(
                dataReader,
                new JsonSerializerOptions
                {
                    ReadCommentHandling = JsonCommentHandling.Skip
                }
            );
        }

    }
}
