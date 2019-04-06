// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using System.Collections.Generic;
using System.IO;
using Xunit;

///////////////////////////////////////////////////////////////////////////////////////////////////
// This file illustrates how to use QCTraceSimulator for metrics calculation of CCNOT gates
///////////////////////////////////////////////////////////////////////////////////////////////////

namespace Microsoft.Quantum.Samples.UnitTesting
{
    public class CCNOTCircuitsMetrics
    {
        /// <summary>
        /// Interface provided by Xunit framework for logging during test execution.
        /// When the test is selected in Visual Studio Test Explore window 
        /// there is an Output text link available for each test. 
        /// </summary>
        private readonly Xunit.Abstractions.ITestOutputHelper output;

        public CCNOTCircuitsMetrics(Xunit.Abstractions.ITestOutputHelper output)
        {
            this.output = output;
        }

        // [Fact] attribute indicates that this function is a usual Xunit test
        [Fact(DisplayName = "CCNOTCircuitsMetrics")]
        public void CCNOTCircuitsMetricsTest()
        {
            // Get an instance of the appropriately configured QCTraceSimulator
            QCTraceSimulator sim = MetricCalculationUtils.GetSimulatorForMetricsCalculation();

            // Run tests against trace simulator to collect metrics
            var result1 = CCNOTCircuitsTest.Run(sim).Result;

            // Let us check that number of T gates in all the circuits is as expected
            string Tcount = PrimitiveOperationsGroupsNames.T;

            // group of circuits with 7 T gates
            Assert.Equal(7, sim.GetMetric<TDepthOneCCNOT,CollectMetrics>(Tcount));
            Assert.Equal(7, sim.GetMetric<CCNOT1, CollectMetrics>(Tcount));
            Assert.Equal(7, sim.GetMetric<CCNOT2, CollectMetrics>(Tcount));
            Assert.Equal(7, sim.GetMetric<CCNOT4, CollectMetrics>(Tcount));

            // group of circuits with 4 T gates
            Assert.Equal(4, sim.GetMetric<CCNOT3, CollectMetrics>(Tcount));
            Assert.Equal(4, sim.GetMetric<UpToPhaseCCNOT1, CollectMetrics>(Tcount));
            Assert.Equal(4, sim.GetMetric<UpToPhaseCCNOT2, CollectMetrics>(Tcount));

            // For UpToPhaseCCNOT3 the number of T gates in it is the number of T
            // gates used in CCNOT plus the number of T gates in Controlled-S
            double expectedTcount =
                sim.GetMetric<Primitive.S, UpToPhaseCCNOT3>(
                    Tcount,
                    functor: Simulation.Core.OperationFunctor.ControlledAdjoint)
                + sim.GetMetric<Primitive.CCNOT, UpToPhaseCCNOT3>(Tcount);

            Assert.Equal(
                expectedTcount, 
                sim.GetMetric<UpToPhaseCCNOT3, CollectMetrics>(Tcount) );

            // The number of extra qubits used by the circuits
            string extraQubits = MetricsNames.WidthCounter.ExtraWidth;
            Assert.Equal(4, sim.GetMetric<TDepthOneCCNOT, CollectMetrics>(extraQubits));

            Assert.Equal(0, sim.GetMetric<CCNOT1, CollectMetrics>(extraQubits));
            Assert.Equal(0, sim.GetMetric<CCNOT2, CollectMetrics>(extraQubits));
            Assert.Equal(0, sim.GetMetric<CCNOT4, CollectMetrics>(extraQubits));
            Assert.Equal(0, sim.GetMetric<UpToPhaseCCNOT1, CollectMetrics>(extraQubits));

            Assert.Equal(2, sim.GetMetric<CCNOT3, CollectMetrics>(extraQubits));
            Assert.Equal(1, sim.GetMetric<UpToPhaseCCNOT2, CollectMetrics>(extraQubits));

            // All of the CCNOT circuit take 3 qubits as an input
            string inputQubits = MetricsNames.WidthCounter.InputWidth;
            Assert.Equal(3, sim.GetMetric<TDepthOneCCNOT, CollectMetrics>(inputQubits));
            Assert.Equal(3, sim.GetMetric<CCNOT1, CollectMetrics>(inputQubits));
            Assert.Equal(3, sim.GetMetric<CCNOT2, CollectMetrics>(inputQubits));
            Assert.Equal(3, sim.GetMetric<UpToPhaseCCNOT1, CollectMetrics>(inputQubits));
            Assert.Equal(3, sim.GetMetric<CCNOT3, CollectMetrics>(inputQubits));
            Assert.Equal(3, sim.GetMetric<UpToPhaseCCNOT2, CollectMetrics>(inputQubits));

            // CCNOT3 uses one measurement 
            Assert.Equal(
                1,
                sim.GetMetric<CCNOT3, CollectMetrics>(PrimitiveOperationsGroupsNames.Measure));

            // Finally, let us check T depth of various CCNOT circuits:
            string tDepth = MetricsNames.DepthCounter.Depth;
            Assert.Equal(1, sim.GetMetric<TDepthOneCCNOT, CollectMetrics>(tDepth));
            Assert.Equal(1, sim.GetMetric<CCNOT3, CollectMetrics>(tDepth));
            Assert.Equal(1, sim.GetMetric<UpToPhaseCCNOT2, CollectMetrics>(tDepth));
            Assert.Equal(4, sim.GetMetric<CCNOT2, CollectMetrics>(tDepth));
            Assert.Equal(5, sim.GetMetric<CCNOT4, CollectMetrics>(tDepth));
            Assert.Equal(5, sim.GetMetric<CCNOT1, CollectMetrics>(tDepth));

            // Finally we write all the collected statistics into CSV files 
            string directory = Directory.GetCurrentDirectory();
            output.WriteLine($"Writing all collected metrics result to" +
                $" {directory}");

            foreach( KeyValuePair<string,string> collectedData in sim.ToCSV() )
            {
                File.WriteAllText(
                    $"{directory}\\CCNOTCircuitsMetrics.{collectedData.Key}.csv", 
                    collectedData.Value);
            }
        }
    }
}
