﻿// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Linq;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Core;
using CommandLine;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Samples.IntegerFactorization
{
    /// <summary>
    /// Common command line options for the application
    /// </summary>
    ///
    /// You can call `dotnet run -- --help` to see a help description for the application
    class CommonOptions
    {
        [Option('n', "number", Required = false, Default = 15, HelpText = "Number to be factoried")]
        public long NumberToFactor { get; set; }

        [Option('m', "method", Required = false, Default = "rpe", HelpText = "Use rpe for Robust Phase Estimation, and qpe for Quantum Phase Estimation")]
        public string Method { get; set; }

        /// <summary>
        /// Helper method to check whether robust phase estimation should be used
        /// </summary>
        public bool UseRobustPhaseEstimation => Method == "rpe";
    }

    [Verb("simulate", isDefault: true, HelpText = "Simulate Shor's algorithm using QDK's full state simulator")]
    class SimulateOptions : CommonOptions
    {
        [Option('t', "trials", Required = false, Default = 100, HelpText = "Number of trials to perform")]
        public long NumberOfTrials { get; set; }
    }

    [Verb("estimate", HelpText = "Estimate the resources to perform one round of period finding in Shor's algorithm")]
    class EstimateOptions : CommonOptions
    {
        [Option('g', "generator", Required = true, HelpText = "A coprime to `number` of which the period is estimated")]
        public long Generator { get; set; }
    }

    [Verb("visualize", HelpText = "Visualize the estimation of the resources to perform one round of period finding in Shor's algorithm")]
    class VisualizeOptions : CommonOptions
    {
        [Option('g', "generator", Required = true, HelpText = "A coprime to `number` of which the period is estimated")]
        public long Generator { get; set; }

        [Option('r', "resource", Required = false, Default = 0, HelpText = "The resource - CNOT: 0; Measure: 1; QubitClifford: 2; R: 3; T: 4")]
        public PrimitiveOperationsGroups Resource { get; set; }
    }


    /// <summary>
    /// This is a Console program that runs Shor's algorithm 
    /// on a Quantum Simulator.
    /// </summary>
    class Program
    {
        static int Main(string[] args) =>
            Parser.Default.ParseArguments<SimulateOptions, EstimateOptions, VisualizeOptions>(args).MapResult(
                (SimulateOptions options) => Simulate(options),
                (EstimateOptions options) => Estimate(options),
                (VisualizeOptions options) => Visualize(options),
                _ => 1
            );

        static int Simulate(SimulateOptions options)
        {
            // Repeat Shor's algorithm multiple times as the algorithm is 
            // probabilistic and there are several ways that it can fail.
            for (int i = 0; i < options.NumberOfTrials; ++i)
            {
                try
                {
                    // Make sure to use simulator within using block. 
                    // This ensures that all resources used by QuantumSimulator
                    // are properly released if the algorithm fails and throws an exception.
                    using (QuantumSimulator sim = new QuantumSimulator())
                    {
                        // Report the number being factored to the standard output
                        Console.WriteLine($"==========================================");
                        Console.WriteLine($"Factoring {options.NumberToFactor}");

                        // Compute the factors
                        (long factor1, long factor2) = 
                            FactorSemiprimeInteger.Run(sim, options.NumberToFactor, options.UseRobustPhaseEstimation).Result;

                        Console.WriteLine($"Factors are {factor1} and {factor2}");

                        // Stop once the factorization has been found
                        break;
                    }
                }
                // Shor's algorithm is a probabilistic algorithm and can fail with certain 
                // probability in several ways. For more details see Shor.qs.
                // If the run of Shor's algorithm fails it throws ExecutionFailException.
                // However, due to the use of System.Task in .Run method,
                // the exception of interest is getting wrapped into AggregateException.
                catch (AggregateException e )
                {
                    // Report the failure of the algorithm to standard output 
                    Console.WriteLine($"This run of Shor's algorithm failed:");

                    // Unwrap AggregateException to get the message from Q# fail statement.
                    // Go through all inner exceptions.
                    foreach (Exception eInner in e.InnerExceptions)
                    {
                        // If the exception of type ExecutionFailException
                        if (eInner is ExecutionFailException failException)
                        {
                            // Print the message it contains
                            Console.WriteLine($"   {failException.Message}");
                        }
                    }
                }
            }

            return 0;
        }

        static int Estimate(EstimateOptions options)
        {
            var config = ResourcesEstimator.RecommendedConfig();
            config.CallStackDepthLimit = 3;

            var estimator = new ResourcesEstimator(config);

            var bitsize = (long)System.Math.Ceiling(System.Math.Log2(options.NumberToFactor + 1));
            EstimateFrequency.Run(estimator, options.Generator, options.NumberToFactor, options.UseRobustPhaseEstimation, bitsize).Wait();

            Console.WriteLine(estimator.ToTSV());

            Console.WriteLine();

            Console.WriteLine(estimator.ToCSV()["PrimitiveOperationsCounter"]);

            return 0;
        }

        static int Visualize(VisualizeOptions options) {
            var config = FlameGraphResourcesEstimator.RecommendedConfig();

            var estimator = new FlameGraphResourcesEstimator(config, options.Resource);

            var bitsize = (long)System.Math.Ceiling(System.Math.Log2(options.NumberToFactor + 1));
            EstimateFrequency.Run(estimator, options.Generator, options.NumberToFactor, options.UseRobustPhaseEstimation, bitsize).Wait();

            Console.WriteLine(string.Join(System.Environment.NewLine, estimator.FlameGraphData.Select(pair => $"{pair.Key} {pair.Value}")));

            return 0;
        }
    }
}
