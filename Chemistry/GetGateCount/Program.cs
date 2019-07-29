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

// We use the Mono.Options and System.Management.Automation
// libraries to make it easy to use this sample from the command line.
using Mono.Options;

// Finally, we include the gate counting logic itself from GetGateCount.cs.
using static Microsoft.Quantum.Chemistry.Samples.GetGateCount;
#endregion

namespace Microsoft.Quantum.Chemistry.Samples
{
    class Program
    {
        static void Main(string[] args)
        {

            string filename = @"..\IntegralData\Liquid\h2s_sto6g_22.dat";
            var format = IntegralDataFormat.Liquid;

            bool runTrotterStep = true;
            bool runMinQubitQubitizationStep = true;
            bool runMinTCountQubitizationStep = true;
            bool showHelp = false;
            string outputFolder = null;

            string logPath = null;

            // These are arguments that can be set from command line.
            var options = new OptionSet {
                { "h|?|help", "Shows this help message.", h => showHelp = true },
                { "p|path=", "Path to the integral data file to use.", f => filename = f },
                { "f|format=",
                    "Format to use when loading integral data.",
                    (string f) => format = (IntegralDataFormat) Enum.Parse(typeof(IntegralDataFormat), f)
                },
                { "t|run-trotter=",
                    "Controls whether the Trotter simulation step will be estimated.",
                    (bool t) => runTrotterStep = t
                },
                { "q|run-qubitization=",
                    "Controls whether the qubitization simulation step that minimizes qubit count will be estimated.",
                    (bool q) => runMinQubitQubitizationStep = q
                },
                { "o|run-optimized-qubitization=",
                    "Controls whether the qubitization simulation step that minimizes T count will be estimated.",
                    (bool o) => runMinTCountQubitizationStep = o
                },
                { "l|log=",
                    "Controls where log messages will be written to.",
                    (string l) => logPath = l
                },
                { "output=",
                    "Specifies the folder into which gate count estimates should be written as CSVs.",
                    (string o) => outputFolder = o
                }
            };

            // This parses the command line arguments, and catches undefined arguments.
            List<string> extra;
            try
            {
                extra = options.Parse(args);
            }
            catch (OptionException)
            {
                ShowHelp(options);
                System.Environment.Exit(1);
            }

            if (showHelp)
            {
                ShowHelp(options);
                System.Environment.Exit(1);
            }

            Logging.LogPath = logPath;
            var logger = Logging.LoggerFactory.CreateLogger<Program>();

            // Here, we specify the Hamiltonian simulation configurations we wish to run.
            var configurations = Configure(
                runTrotterStep: runTrotterStep,
                runMinQubitQubitizationStep: runMinQubitQubitizationStep,
                runMinTCountQubitizationStep: runMinTCountQubitizationStep);

            using (logger.BeginScope($"Using {filename}."))
            {
                logger.LogInformation($"Loading...");

                // Read Hamiltonian terms from file and run gate counts.
                var gateCountResults = RunGateCount(filename, format, configurations, outputFolder).Result;

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

        public static void ShowHelp(OptionSet options)
        {
            System.Console.WriteLine("get-gatecount");
            System.Console.WriteLine("Usage:");
            options.WriteOptionDescriptions(Console.Out);
            return;
        }
    }

}

