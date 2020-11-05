// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Core;
using CommandLine;

namespace Microsoft.Quantum.Samples.IntegerFactorization
{
    /// <summary>
    /// Command line options for the application
    /// </summary>
    ///
    /// You can call `dotnet run -- --help` to see a help description for the application
    class Options
    {
        [Option('n', "number", Required = false, Default = 15, HelpText = "Number to be factoried")]
        public long NumberToFactor { get; set; }

        [Option('t', "trials", Required = false, Default = 100, HelpText = "Number of trials to perform")]
        public long NumberOfTrials { get; set; }

        [Option('m', "method", Required = false, Default = "rpe", HelpText = "Use rpe for Robust Phase Estimation, and qpe for Quantum Phase Estimation")]
        public string Method { get; set; }

        public bool UseRobustPhaseEstimation => Method == "rpe";
    }

    /// <summary>
    /// This is a Console program that runs Shor's algorithm 
    /// on a Quantum Simulator.
    /// </summary>
    class Program
    {
        static int Main(string[] args) =>
            Parser.Default.ParseArguments<Options>(args).MapResult(
                options => Simulate(options),
                _ => 1
            );

        static int Simulate(Options options)
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
    }
}