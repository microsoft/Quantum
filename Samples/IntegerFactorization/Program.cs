// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Samples.IntegerFactorization
{
    /// <summary>
    /// This is a Console program that runs Shor's algorithm 
    /// on a Quantum Simulator.
    /// </summary>
    class Program
    {
        // The console application takes up to three arguments
        // 1. numberToFactor -- number to be factored 
        // 2. nTrials -- number of trial to perform 
        // 3. useRobustPhaseEstimation -- if true uses Robust Phase Estimation, 
        //                                uses Quantum Phase Estimation otherwise.
        // If you build the Debug configuration, the executable will be located in 
        // Libraries\Samples\IntegerFactorization\bin\Debug\ folder;
        // for the Release configuration the folder is 
        // Libraries\Samples\IntegerFactorization\bin\Release.
        // The name of the executable is IntegerFactorization.exe.
        static void Main(string[] args)
        {
            // Default values used if no arguments are provided
            long numberToFactor = 15;
            long nTrials = 100;
            bool useRobustPhaseEstimation = true;

            // Parse the arguments provided in command line
            if( args.Length >= 1 )
            {
                // The first argument is the number to factor
                Int64.TryParse(args[0], out numberToFactor);
            }

            if (args.Length >= 2 )
            {
                // The second is the number of trials 
                Int64.TryParse(args[1], out nTrials);
            }

            if (args.Length >= 3)
            {
                // The third argument indicates if Robust or Quantum Phase Estimation 
                // should be used
                bool.TryParse(args[2], out useRobustPhaseEstimation);
            }

            // Repeat Shor's algorithm multiple times as the algorithm is 
            // probabilistic and there are several ways how it can fail.
            for (int i = 0; i < nTrials; ++i)
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
                        Console.WriteLine($"Factoring {numberToFactor}");

                        // Compute the factors
                        (long factor1, long factor2) = 
                            Shor.Run(sim, numberToFactor, useRobustPhaseEstimation).Result;

                        Console.WriteLine($"Factors are {factor1} and {factor2}");
                    }
                }
                // Shor's algorithm is a probabilistic algorithm and can fail with certain 
                // probability in several ways. For more details see Shor.qs.
                // If the run of Shor's algorithm fails is throws ExecutionFailException.
                // However, dues to the use of System.Task in .Run method,
                // the exception of interest is 
                // getting wrapped into AggregateException. 
                catch (AggregateException e )
                {
                    // Report the failure of the algorithm to standard output 
                    Console.WriteLine($"This run of Shor's algorithm failed:");

                    // Unwrap AggregateException to get the message from Q# fail statement.
                    // Go through all inner exceptions.
                    foreach ( Exception eInner in e.InnerExceptions )
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
        }
    }
}