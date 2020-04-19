// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#region Using Statements
// We will need several different libraries in this sample.
// Here, we expose these libraries to our program using the
// C# "using" statement, similar to the Q# "open" statement.

// The System namespace provides a number of useful built-in
// types and methods that we'll use throughout this sample.
using System;

// The System.Collections.Generic library provides many different
// utilities for working with collections such as lists and dictionaries.
using System.Collections.Generic;

// We use the logging library provided with .NET Core to handle output
// in a robust way that makes it easy to turn on and off different messages.
using Microsoft.Extensions.Logging;

// We use the McMaster.Extensions.CommandLineUtils
// library to make it easy to use this sample from the command line.
using McMaster.Extensions.CommandLineUtils;

// Finally, we include the gate counting logic itself from GetGateCount.cs.
using static Microsoft.Quantum.Chemistry.Samples.GetGateCount;
#endregion

namespace Microsoft.Quantum.Chemistry.Samples
{
    class Program
    {
        public static int Main(string[] args) =>
            CommandLineApplication.Execute<Program>(args);
        

        [Option("-p|--path", Description = "Path to the integral data file to use.")]
        public string Path { get; } = System.IO.Path.Combine(
            "..", "IntegralData", "Liquid", "h2s_sto6g_22.dat"
        );

        [Option("-f|--format", Description="Format to use when loading integral data.")]
        public IntegralDataFormat Format { get; } = IntegralDataFormat.Liquid;

        [Option("--skip-trotter-suzuki", Description="If set, skips estimating for the Trotter–Suzuki simulation step.")]
        public bool SkipTrotterSuzuki { get; } = false;
        public bool RunTrotterSuzuki => !SkipTrotterSuzuki;

        [Option("--skip-qubitization", Description = "If set, skips estimating for the qubitized simulation step.")]
        public bool SkipQubitization { get; } = false;
        public bool RunQubitization => !SkipQubitization;

        [Option("--skip-opt-qubitization", Description = "If set, skips estimating for the optimized qubitized simulation step.")]
        public bool SkipOptimizedQubitization { get; } = false;
        public bool RunOptimizedQubitization => !SkipOptimizedQubitization;

        [Option("-l|--log", Description = "Controls where log messages will be written to.")]
        public string LogPath { get; } = null;

        [Option("-o|--output", Description = "Specifies the folder into which gate count estimates should be written as CSVs.")]
        public string OutputPath { get; } = null;
        

        void OnExecute()
        {
            if (LogPath != null)
            {
                Logging.LogPath = LogPath;
            }
            var logger = Logging.LoggerFactory.CreateLogger<Program>();

            // Here, we specify the Hamiltonian simulation configurations we wish to run.
            var configurations = Configure(
                runTrotterStep: RunTrotterSuzuki,
                runMinQubitQubitizationStep: RunQubitization,
                runMinTCountQubitizationStep: RunOptimizedQubitization
            );

            using (logger.BeginScope($"Using {Path}."))
            {
                logger.LogInformation($"Loading...");

                // Read Hamiltonian terms from file and run gate counts.
                var gateCountResults = RunGateCount(Path, Format, configurations, OutputPath).Result;

                foreach(var result in gateCountResults)
                {
                    Console.WriteLine(result.ToString());
                }
            }

            if (System.Diagnostics.Debugger.IsAttached)
            {
                System.Console.ReadLine();
            }
        }

    }

}

