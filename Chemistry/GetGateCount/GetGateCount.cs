// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// This loads a Hamiltonian from file and performs gate estimates of a
// - Jordan–Wigner Trotter step
// - Jordan–Wigner Qubitization iterate

#region Using Statements
// We will need several different libraries in this sample.
// Here, we expose these libraries to our program using the
// C# "using" statement, similar to the Q# "open" statement.

// We will use the data model implemented by the Quantum Development Kit Chemistry
// Libraries. This model defines what a fermionic Hamiltonian is, and how to
// represent Hamiltonians on disk.
using Microsoft.Quantum.Chemistry;
using Microsoft.Quantum.Chemistry.OrbitalIntegrals;
using Microsoft.Quantum.Chemistry.JordanWigner;
using Microsoft.Quantum.Chemistry.Fermion;
using Microsoft.Quantum.Chemistry.QSharpFormat;

// To count gates, we'll use the trace simulator provided with
// the Quantum Development Kit.
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

// The System namespace provides a number of useful built-in
// types and methods that we'll use throughout this sample.
using System.Linq;

// The System.Diagnostics namespace provides us with the
// Stopwatch class, which is quite useful for measuring
// how long each gate counting run takes.
using System.Diagnostics;

// The System.Collections.Generic library provides many different
// utilities for working with collections such as lists and dictionaries.
using System.Collections.Generic;


// Finally, we use the Mono.Options and System.Management.Automation
// libraries to make it easy to use this sample from the command line.
using System.Threading.Tasks;
#endregion

namespace Microsoft.Quantum.Chemistry.Samples
{

    // We begin by specifying a data structure that we can use to hold
    // results from gate counting a particular method on a particular
    // integral data set.
    public class GateCountResults
    {
        public string IntegralDataPath;
        public string Method;
        public double SpinOrbitals;
        public double TCount;
        public double RotationsCount;
        public double CNOTCount;
        public double NormMultipler;
        public long ElapsedMilliseconds;
        public Dictionary<string, string> TraceSimulationStats;

        public override string ToString() =>
            $"Gate Count results on {IntegralDataPath}\r\n" +
            $"by {Method} with {SpinOrbitals} spin-orbitals. It took {ElapsedMilliseconds} ms.\r\n" +
            $"Gate count statistics: \r\n" +
            $"# T:{TCount}, \r\n" +
            $"# Rotations:{RotationsCount}, \r\n" +
            $"# CNOT:{CNOTCount}, \r\n" +
            $"Norm Multipler:{NormMultipler}";
    }

    static class GetGateCount
    {

        // This convenience method configures the simulation algorithm to be run.
        public static IEnumerable<HamiltonianSimulationConfig> Configure(
            bool runTrotterStep = true,
            bool runMinQubitQubitizationStep = true, 
            bool runMinTCountQubitizationStep = true)
        {
            // Here, we specify the Hamiltonian simulation configurations we wish to run.
            if (runTrotterStep)
            {
                // First-order product formula. Note that we only apply a single Trotter step, so the stepSize parameter does not affect gate counts.
                yield return new HamiltonianSimulationConfig(
                    new ProductFormulaConfig { StepSize = 1.0, Order = 1 }
                );
            }
            if (runMinQubitQubitizationStep)
            {
                // Quantum walk by Qubitization that minimizes the Qubit count.
                yield return new HamiltonianSimulationConfig(
                    new QubitizationConfig { QubitizationStatePrep = QubitizationStatePrep.MinimizeQubitCount }
                );
            }
            if (runMinTCountQubitizationStep)
            {
                // Quantum walk by Qubitization that minimizes the T count.
                yield return new HamiltonianSimulationConfig(
                    new QubitizationConfig { QubitizationStatePrep = QubitizationStatePrep.MinimizeTGateCount }
                );
            }
        }

        // This method computes the gate count of simulation by all configurations passed to it.
        internal static async Task<IEnumerable<GateCountResults>> RunGateCount(
            string filename, IntegralDataFormat format, IEnumerable<HamiltonianSimulationConfig> configurations,
            string outputFolder = null
        )
        {
            // To get the data for exporting to Q#, we proceed in several steps.
            var jordanWignerEncoding =
                // First, we deserialize the file given by filename, using the
                // format given by format.
                format.Map(
                    (IntegralDataFormat.Liquid, () => LiQuiD.Deserialize(filename).Select(o => o.OrbitalIntegralHamiltonian)),
                    (IntegralDataFormat.Broombridge, () => Broombridge.Deserializers.DeserializeBroombridge(filename).ProblemDescriptions.Select(o => o.OrbitalIntegralHamiltonian))
                )
                // In general, Broombridge allows for loading multiple Hamiltonians
                // from a single file. For the purpose of simplicitly, however,
                // we'll only load a single Hamiltonian from each file in this
                // sample. We use .Single here instead of .First to make sure
                // that we raise an error instead of silently discarding data.
                .Single()
                // Next, we convert to a fermionic Hamiltonian using the UpDown
                // convention.
                .ToFermionHamiltonian(IndexConvention.UpDown)
                // Finally, we use the optimized Jordan–Wigner representation
                // to convert to a qubit Hamiltonian that we can export to
                // a format understood by Q#.
                .ToPauliHamiltonian(Paulis.QubitEncoding.JordanWigner);

            // We save the exported Q# data into a variable that we can pass
            // to the trace simulator.
            var qSharpData = jordanWignerEncoding
                .ToQSharpFormat()
                .Pad();

            var gateCountResults = new List<GateCountResults>();

            foreach (var config in configurations)
            {
                var results = await RunGateCount(qSharpData, config, outputFolder);
                results.IntegralDataPath = filename;
                results.SpinOrbitals = jordanWignerEncoding.SystemIndices.Count();
                gateCountResults.Add(results);
            }

            return gateCountResults;
        }

        // This method computes the gate count of simulation a single configuration passed to it.
        internal static async Task<GateCountResults> RunGateCount(
            JordanWignerEncodingData qSharpData, HamiltonianSimulationConfig config,
            string outputFolder = null
        )
        {
            // Creates and configures Trace simulator for accumulating gate counts.
            var sim = CreateAndConfigureTraceSim();

            // Create stop-watch to measure the execution time
            var stopWatch = new Stopwatch();

            var gateCountResults = new GateCountResults();
            #region Trace Simulator on Trotter step
            if (config.HamiltonianSimulationAlgorithm == HamiltonianSimulationAlgorithm.ProductFormula)
            {
                var res = await stopWatch.Measure(async () => await RunTrotterStep.Run(sim, qSharpData));

                gateCountResults = new GateCountResults
                {
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
                if (outputFolder != null)
                {
                    sim.WriteResultsToFolder(outputFolder, "TrotterGateCountEstimates");
                }

            }
            #endregion

            #region Trace Simulator on Qubitization step
            if (config.HamiltonianSimulationAlgorithm == HamiltonianSimulationAlgorithm.Qubitization)
            {
                if (config.QubitizationConfig.QubitizationStatePrep == QubitizationStatePrep.MinimizeQubitCount)
                {
                    var res = await stopWatch.Measure(async () => await RunQubitizationStep.Run(sim, qSharpData));

                    gateCountResults = new GateCountResults
                    {
                        Method = "Qubitization",
                        ElapsedMilliseconds = stopWatch.ElapsedMilliseconds,
                        RotationsCount = sim.GetMetric<RunQubitizationStep>(PrimitiveOperationsGroupsNames.R),
                        TCount = sim.GetMetric<RunQubitizationStep>(PrimitiveOperationsGroupsNames.T),
                        CNOTCount = sim.GetMetric<RunQubitizationStep>(PrimitiveOperationsGroupsNames.CNOT),
                        TraceSimulationStats = sim.ToCSV(),
                        NormMultipler = res
                    };

                    // Dump all the statistics to CSV files, one file per statistics collector
                    // FIXME: the names here aren't varied, and so the CSVs will get overwritten when running many
                    //        different Hamiltonians.
                    if (outputFolder != null)
                    {
                        sim.WriteResultsToFolder(outputFolder, "QubitizationGateCountEstimates");
                    }
                }
            }
            #endregion

            #region Trace Simulator on Optimized Qubitization step
            if (config.HamiltonianSimulationAlgorithm == HamiltonianSimulationAlgorithm.Qubitization)
            {
                if (config.QubitizationConfig.QubitizationStatePrep == QubitizationStatePrep.MinimizeTGateCount)
                {
                    // This primarily affects the Qubit count and CNOT count.
                    // The T-count only has a logarithmic dependence on this parameter.
                    var targetError = 0.001;
                    var res = await stopWatch.Measure(async () => await RunOptimizedQubitizationStep.Run(sim, qSharpData, targetError));
                    stopWatch.Stop();

                    gateCountResults = new GateCountResults
                    {
                        Method = "Optimized Qubitization",
                        ElapsedMilliseconds = stopWatch.ElapsedMilliseconds,
                        RotationsCount = sim.GetMetric<RunOptimizedQubitizationStep>(PrimitiveOperationsGroupsNames.R),
                        TCount = sim.GetMetric<RunOptimizedQubitizationStep>(PrimitiveOperationsGroupsNames.T),
                        CNOTCount = sim.GetMetric<RunOptimizedQubitizationStep>(PrimitiveOperationsGroupsNames.CNOT),
                        TraceSimulationStats = sim.ToCSV(),
                        NormMultipler = res
                    };

                    // Dump all the statistics to CSV files, one file per statistics collector
                    // FIXME: the names here aren't varied, and so the CSVs will get overwritten when running many
                    //        different Hamiltonians.
                    if (outputFolder != null)
                    {
                        sim.WriteResultsToFolder(outputFolder, "OptimizedQubitizationGateCountEstimates");
                    }
                }
            }
            #endregion

            return gateCountResults;
        }

        #region Configure trace simulator
        private static QCTraceSimulator CreateAndConfigureTraceSim() =>
            new QCTraceSimulator(
                new QCTraceSimulatorConfiguration()
                {
                    UsePrimitiveOperationsCounter = true,
                    ThrowOnUnconstrainedMeasurement = false
                }
            );
        #endregion
    }

}

