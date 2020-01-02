
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

    class Program
    {
        static async Task Main(string[] args)
        {
            const int hardMaxRestarts = 16; //Based on the parameter resource
            int maxRestarts = hardMaxRestarts;

            System.Random rand = new Random(12345678);

            List<double[]> paramSource = new List<double[]>(hardMaxRestarts);
            for (int ir = 0; ir < hardMaxRestarts; ir++)
            {
                double[] pars = new double[circStruct.Count];
                for (int ipr = 0; ipr < circStruct.Count; ipr++)
                {
                    pars[ipr] = Math.PI * (rand.NextDouble() - 0.5); 
                }
                paramSource.Add(pars);
            }



            double learningRate = 0.4; //LKG learning rate
            long mbSize = 2L; //Recommended 
            double tol = 0.001;

            List<long[]> schedAll = new List<long[]>();
            schedAll.Add(new long[] { 0L, 1L, (long)(vectors.Count - 1) });
            var model = new ClassificationModel(nQubits: 4L, circStruct);
            var trainingStart = DateTime.Now;
            model.QcccTrainParallel(paramSource.GetRange(0, maxRestarts), vectors, labels, trainingSchedule: schedAll,
                validationSchedule: schedAll, learningRate, tolerance: tol, mbSize, maxEpochs: 16L, nMeasurements: 10000L, randomizationSeed: 12345678);
            var elapsedTrainingMS = (DateTime.Now - trainingStart).TotalMilliseconds;
            var elapsedTrainingS = (DateTime.Now - trainingStart).TotalSeconds;
            var trainingScore = model.CountMisclassifications(tol,vectors, labels, nMeasurements: 10000L, randomizationSeed: 12345678);

            ret = (trainingScore < 6L);
            if (ret)
            {
                Console.WriteLine("Wine training test (parallel) SUCCEDED! [with " + circStruct.Count.ToString() + " parameters]");
            }
            else
            {
                if (trainingScore < 8L)
                {
                    Console.WriteLine("Wine training test (parallel) SLIPPED with " + trainingScore.ToString() + " misses. [had " + circStruct.Count.ToString() + " parameters]");
                    Console.WriteLine("Try rerunning the test. Could be due to simulator fuzz.");
                }
                else
                {
                    Console.WriteLine("Wine training test (parallel) FAILED with " + trainingScore.ToString() + " misses. [had " + circStruct.Count.ToString() + " parameters]");
                }
            }

            var testScore = model.CountMisclassifications(tol,testVectors, testLabels, nMeasurements: 10000L, randomizationSeed: 12345678);
 
            return ret;
        } //StandardLayersExample
    }
}
