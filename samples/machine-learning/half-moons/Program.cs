using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.IO;
using System.Linq;
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
        /// <summary>
        /// Simple 2D data classes that are, however, not linearly separable
        /// </summary>
        /// <returns>true iff fewer that 3 misclassifications are achieved on test data</returns>
        static async Task Main()
        {
            var (vectors, labels) = LoadDataFromCsv("sorted-data.csv");
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
                new QArray<QArray<double>>(vectors.Select(vector => new QArray<double>(vector))),
                new QArray<long>(labels),
                new QArray<QArray<double>>(paramSource.Select(parameterSet => new QArray<double>(parameterSet)))
            );

            //NOW DO SOME TESTING
            var (testVecs, testLabs) = LoadDataFromCsv("moon-test.csv");
            var testMisses = await ValidateHalfMoonModel.Run(
                targetMachine,
                new QArray<QArray<double>>(testVecs.Select(vector => new QArray<double>(vector))),
                new QArray<long>(testLabs),
                optimizedParameters,
                optimizedBias
            );
            System.Console.WriteLine($"Observed {testMisses} misclassifications out of {testVecs.Count} validation samples.");
        } //HalfMoonsExample


        static (List<double[]>, List<long>) LoadDataFromCsv(string dataPath, double offset = 0.0, double filler = 1.0)
        {
            var vectors = new List<double[]>();
            var labels = new List<long>();
            using var dataReader = new StreamReader(dataPath);
            while (dataReader.ReadLine() is string line)
            {
                var tokens = line.Split(',');
                var x = double.Parse(tokens[0]) + offset;
                var y = double.Parse(tokens[1]) + offset;
                //pre-applying "product state" kernel
                var vec = new double[] { x, y };
                vectors.Add(vec);
                labels.Add(long.Parse(tokens[2]));
            }
            return (vectors, labels);
        }

    }
}
