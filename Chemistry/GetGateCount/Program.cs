// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// This loads a Hamiltonian from file and performs gate estimates of a
// - Jordan-Wigner Trotter step
// - Jordan-Wigner Qubitization iterate

#region Using Statements
// We will need several different libraries in this sample.
// Here, we expose these libraries to our program using the
// C# "using" statement, similar to the Q# "open" statement.

// We will use the data model implemented by the Quantum Development Kit Chemistry
// Libraries. This model defines what a fermionic Hamiltonian is, and how to
// represent Hamiltonians on disk.
using Microsoft.Quantum.Chemistry;
using Microsoft.Quantum.Chemistry.JordanWigner;

// To count gates, we'll use the trace simulator provided with
// the Quantum Development Kit.
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

// The System namespace provides a number of useful built-in
// types and methods that we'll use throughout this sample.
using System;
using System.Linq;

// The System.Diagnostics namespace provides us with the
// Stopwatch class, which is quite useful for measuring
// how long each gate counting run takes.
using System.Diagnostics;

// The System.Collections.Generic library provides many different
// utilities for working with collections such as lists and dictionaries.
using System.Collections.Generic;

// We use the logging library provided with .NET Core to handle output
// in a robust way that makes it easy to turn on and off different messages.
using Microsoft.Extensions.Logging;

// Finally, we use the Mono.Options and System.Management.Automation
// libraries to make it easy to use this sample from the command line.
using Mono.Options;
using System.Management.Automation;
using System.Threading.Tasks;
#endregion

namespace Microsoft.Quantum.Chemistry.Samples
{
    using ProductFormulaConfig = HamiltonianSimulationConfig.ProductFormulaConfig;
    using QubitizationConfig = HamiltonianSimulationConfig.QubitizationConfig;

    
    // We begin by specifying a data structure that we can use to hold
    // results from gate counting a particular method on a particular
    // integral data set.
    public class GateCountResults
    {
        public string IntegralDataPath;
        public string HamiltonianName;
        public string Method;
        public double SpinOrbitals;
        public double TCount;
        public double RotationsCount;
        public double CNOTCount;
        public double NormMultipler;
        public long ElapsedMilliseconds;
        public Dictionary<string, string> TraceSimulationStats;

        public override string ToString()
        {
            return $"Gate Count results on {IntegralDataPath}\r\n" +
                    $"by {Method} with {SpinOrbitals} spin-orbitals. It took {ElapsedMilliseconds} ms.\r\n" +
                    $"Gate count statistics: \r\n" +
                    $"# T:{TCount}, \r\n" +
                    $"# Rotations:{RotationsCount}, \r\n" +
                    $"# CNOT:{CNOTCount}, \r\n" +
                    $"Norm Multipler:{NormMultipler}";
        }
    }

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

            if (showHelp) {
                ShowHelp(options);
                System.Environment.Exit(1);
            }

            Logging.LogPath = logPath;
            var logger = Logging.LoggerFactory.CreateLogger<Program>();

            // Here, we specify the Hamiltonian simulation configurations we wish to run.
            var configurations = MakeConfig(
                runTrotterStep: runTrotterStep,
                runMinQubitQubitizationStep: runMinQubitQubitizationStep,
                runMinTCountQubitizationStep: runMinTCountQubitizationStep);

            using (logger.BeginScope($"Using {filename}."))
            {
                logger.LogInformation($"Loading...");

                // Read Hamiltonian terms from file and run gate counts.
                var gateCountResults = RunGateCount(filename, format, configurations).Result;

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

        // This convenience method configures the simulation algorithm to be run.
        public static List<HamiltonianSimulationConfig> MakeConfig(
            bool runTrotterStep = true,
            bool runMinQubitQubitizationStep = true, 
            bool runMinTCountQubitizationStep = true)
        {
            // Here, we specify the Hamiltonian simulation configurations we wish to run.
            var configurations = new List<HamiltonianSimulationConfig>();
            if (runTrotterStep)
            {
                // First-order product formula. Note that we only apply a single Trotter step, so the stepSize parameter does not affect gate counts.
                configurations.Add(new HamiltonianSimulationConfig(new ProductFormulaConfig { StepSize = 1.0, Order = 1 }));
            }
            if (runMinQubitQubitizationStep)
            {
                // Quantum walk by Qubitization that minimizes the Qubit count.
                configurations.Add(new HamiltonianSimulationConfig(new QubitizationConfig { qubitizationStatePrep = QubitizationConfig.QubitizationStatePrep.MinimizeQubitCount }));

            }
            if (runMinTCountQubitizationStep)
            {
                // Quantum walk by Qubitization that minimizes the T count.
                configurations.Add(new HamiltonianSimulationConfig(new QubitizationConfig { qubitizationStatePrep = QubitizationConfig.QubitizationStatePrep.MinimizeTGateCount }));
            }
            return configurations;
        }

        // This method computes the gate count of simulation by all configurations passed to it.
        internal static async Task<IEnumerable<GateCountResults>> RunGateCount(string filename, IntegralDataFormat format, IEnumerable<HamiltonianSimulationConfig> configurations)
        {
            // Read Hamiltonian terms from file.
            IEnumerable<FermionHamiltonian> hamiltonians =
                format.Map(
                    (IntegralDataFormat.Liquid, () => FermionHamiltonian.LoadFromLiquid(filename)),
                    (IntegralDataFormat.YAML, () => FermionHamiltonian.LoadFromYAML(filename))
                );

            var hamiltonian = hamiltonians.First();

            // Process Hamiltonitn to obtain optimized Jordan-Wigner representation.
            var jordanWignerEncoding = JordanWignerEncoding.Create(hamiltonian);

            // Convert to format for consumption by Q# algorithms.
            var qSharpData = jordanWignerEncoding.QSharpData();

            var gateCountResults = new List<GateCountResults>();

            foreach (var config in configurations)
            {
                GateCountResults results = await RunGateCount(qSharpData, config);
                results.HamiltonianName = hamiltonian.Name;
                results.IntegralDataPath = filename;
                results.SpinOrbitals = jordanWignerEncoding.NSpinOrbitals;
                gateCountResults.Add(results);
            }

            return gateCountResults;
        }

        // This method computes the gate count of simulation a single configuration passed to it.
        internal static async Task<GateCountResults> RunGateCount(JordanWignerEncodingData qSharpData, HamiltonianSimulationConfig config)
        {
            // Creates and configures Trace simulator for accumulating gate counts.
            QCTraceSimulator sim = CreateAndConfigureTraceSim();

            // Create stop-watch to measure the execution time
            Stopwatch stopWatch = new Stopwatch();

            var gateCountResults = new GateCountResults();
            #region Trace Simulator on Trotter step
            if (config.hamiltonianSimulationAlgorithm == HamiltonianSimulationConfig.HamiltonianSimulationAlgorithm.ProductFormula)
            {
                stopWatch.Reset();
                stopWatch.Start();
                var res = await RunTrotterStep.Run(sim, qSharpData);
                
                stopWatch.Stop();
                
                gateCountResults = new GateCountResults {
                    Method = "Trotter",
                    ElapsedMilliseconds = stopWatch.ElapsedMilliseconds,
                    RotationsCount = sim.GetMetric<RunTrotterStep>(PrimitiveOperationsGroupsNames.R),
                    TCount = sim.GetMetric<RunTrotterStep>(PrimitiveOperationsGroupsNames.T),
                    CNOTCount = sim.GetMetric<RunTrotterStep>(PrimitiveOperationsGroupsNames.CNOT),
                    TraceSimulationStats = sim.ToCSV()
                };

                // Dump all the statistics to CSV files, one file per statistics collector
                // FIXME: the names here aren't varied, and so the CSVs will get overwritten when running many
                //        different Hamiltonians.
                var gateStats = sim.ToCSV();
                foreach (var x in gateStats)
                {
                    System.IO.File.WriteAllLines($"TrotterGateCountEstimates.{x.Key}.csv", new string[] { x.Value });
                }
                
            }
            #endregion

            #region Trace Simulator on Qubitization step
            if (config.hamiltonianSimulationAlgorithm == HamiltonianSimulationConfig.HamiltonianSimulationAlgorithm.Qubitization)
            {
                if (config.qubitizationConfig.qubitizationStatePrep == HamiltonianSimulationConfig.QubitizationConfig.QubitizationStatePrep.MinimizeQubitCount)
                {
                    stopWatch.Reset();
                    stopWatch.Start();
                    var res = await RunQubitizationStep.Run(sim, qSharpData);

                    stopWatch.Stop();

                    gateCountResults = new GateCountResults
                    {
                        Method = "Qubitization",
                        ElapsedMilliseconds = stopWatch.ElapsedMilliseconds,
                        RotationsCount = sim.GetMetric<RunQubitizationStep>(PrimitiveOperationsGroupsNames.R),
                        TCount = sim.GetMetric<RunQubitizationStep>(PrimitiveOperationsGroupsNames.T),
                        CNOTCount = sim.GetMetric<RunQubitizationStep>(PrimitiveOperationsGroupsNames.CNOT),
                        TraceSimulationStats = sim.ToCSV()
                    };

                    // Dump all the statistics to CSV files, one file per statistics collector
                    // FIXME: the names here aren't varied, and so the CSVs will get overwritten when running many
                    //        different Hamiltonians.
                    var gateStats = sim.ToCSV();
                    foreach (var x in gateStats)
                    {
                        System.IO.File.WriteAllLines($"QubitizationGateCountEstimates.{x.Key}.csv", new string[] { x.Value });
                    }
                }
            }
            #endregion

            #region Trace Simulator on Optimized Qubitization step
            if (config.hamiltonianSimulationAlgorithm == HamiltonianSimulationConfig.HamiltonianSimulationAlgorithm.Qubitization)
            {
                if (config.qubitizationConfig.qubitizationStatePrep == HamiltonianSimulationConfig.QubitizationConfig.QubitizationStatePrep.MinimizeTGateCount)
                {
                    stopWatch.Reset();
                    stopWatch.Start();

                    // This primarily affects the Qubit count and CNOT count.
                    // The T-count only has a logarithmic dependence on this parameter.
                    var targetError = 0.001;

                    var res = await RunOptimizedQubitizationStep.Run(sim, qSharpData, targetError);

                    stopWatch.Stop();

                    gateCountResults = new GateCountResults
                    {
                        Method = "Optimized Qubitization",
                        ElapsedMilliseconds = stopWatch.ElapsedMilliseconds,
                        RotationsCount = sim.GetMetric<RunOptimizedQubitizationStep>(PrimitiveOperationsGroupsNames.R),
                        TCount = sim.GetMetric<RunOptimizedQubitizationStep>(PrimitiveOperationsGroupsNames.T),
                        CNOTCount = sim.GetMetric<RunOptimizedQubitizationStep>(PrimitiveOperationsGroupsNames.CNOT),
                        TraceSimulationStats = sim.ToCSV()
                    };

                    // Dump all the statistics to CSV files, one file per statistics collector
                    // FIXME: the names here aren't varied, and so the CSVs will get overwritten when running many
                    //        different Hamiltonians.
                    var gateStats = sim.ToCSV();
                    foreach (var x in gateStats)
                    {
                        System.IO.File.WriteAllLines($"OptimizedQubitizationGateCountEstimates.{x.Key}.csv", new string[] { x.Value });
                    }
                }
            }
            #endregion

            return gateCountResults;
        }

        #region Configure trace simulator
        private static QCTraceSimulator CreateAndConfigureTraceSim()
        {
            // Create and configure Trace Simulator
            var config = new QCTraceSimulatorConfiguration()
            {
                usePrimitiveOperationsCounter = true,
                throwOnUnconstraintMeasurement = false
            };

            return new QCTraceSimulator(config);
        }
        #endregion

        
    }

    #region Gate count configuration file

    /// <summary>
    /// Configuration data for Hamiltonian simulation algorithm
    /// </summary>
    public struct HamiltonianSimulationConfig
    {
        /// <summary>
        /// Choice of Hamiltonian simulation algorithm
        /// </summary>
        public HamiltonianSimulationAlgorithm hamiltonianSimulationAlgorithm;
        /// <summary>
        /// Configuration for <see cref="HamiltonianSimulationAlgorithm.ProductFormula"/>.
        /// </summary>
        public ProductFormulaConfig productFormulaConfig;
        /// <summary>
        /// Configuration for <see cref="HamiltonianSimulationAlgorithm.Qubitization"/>.
        /// </summary>
        public QubitizationConfig qubitizationConfig;
        /// <summary>
        /// Hamiltonian simulation algorithm configuration constructor.
        /// </summary>
        /// <param name="setProductFormulaConfig">Product formula configuration</param>
        public HamiltonianSimulationConfig(ProductFormulaConfig setProductFormulaConfig = new ProductFormulaConfig())
        {
            hamiltonianSimulationAlgorithm = HamiltonianSimulationAlgorithm.ProductFormula;
            productFormulaConfig = setProductFormulaConfig;
            // Default settings for all other parameters
            qubitizationConfig = new QubitizationConfig();
        }
        /// <summary>
        /// Hamiltonian simulation algorithm configuration constructor.
        /// </summary>
        /// <param name="setQubitizationConfig">Qubitization formula configuration</param>
        public HamiltonianSimulationConfig(QubitizationConfig setQubitizationConfig = new QubitizationConfig())
        {
            hamiltonianSimulationAlgorithm = HamiltonianSimulationAlgorithm.Qubitization;
            qubitizationConfig = setQubitizationConfig;
            // Default settings for all other parameters
            productFormulaConfig = new ProductFormulaConfig();
        }
        /// <summary>
        /// Enumeration type for choice of Hamiltonian simulation algorithm
        /// </summary>
        public enum HamiltonianSimulationAlgorithm
        {
            ProductFormula,
            Qubitization
        };
        /// <summary>
        /// Configuration data for product formula simulation algorithm
        /// </summary>
        public struct ProductFormulaConfig
        {
            /// <summary>
            /// Order of product formula integrator.
            /// </summary>
            public Int64 Order;
            /// <summary>
            /// Step-size of product formula
            /// </summary>
            public Double StepSize;
            /// <summary>
            /// Product formula configuration constructor.
            /// </summary>
            /// <param name="setStepSize">Step size of integrator</param>
            /// <param name="setOrder">Order of integrator</param>
            public ProductFormulaConfig(Double setStepSize, Int64 setOrder = 1)
            {
                Order = setOrder;
                if (setOrder > 2)
                {
                    throw new System.NotImplementedException($"Product formulas of order > 2 not implemented.");
                }
                StepSize = setStepSize;
            }
        };
        /// <summary>
        /// Configuration data for Qubitization simulation algorithm
        /// </summary>
        public struct QubitizationConfig
        {
            /// <summary>
            /// Choice of quantum state preparation
            /// </summary>
            public QubitizationStatePrep qubitizationStatePrep;
            /// <summary>
            /// Qubitization configuration constructor.
            /// </summary>
            /// <param name="setQubitizationStatePrep">Choice of quantum state preparation algorithm</param>
            public QubitizationConfig(QubitizationStatePrep setQubitizationStatePrep = QubitizationStatePrep.MinimizeQubitCount)
            {
                qubitizationStatePrep = setQubitizationStatePrep;
            }
            /// <summary>
            /// Enumeration type for choice of quantum state preparation.
            /// </summary>
            public enum QubitizationStatePrep
            {
                MinimizeQubitCount,
                MinimizeTGateCount
            }

        }
    }
    #endregion


}

