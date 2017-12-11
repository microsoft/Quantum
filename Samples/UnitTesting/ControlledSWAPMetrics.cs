// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using Xunit;

///////////////////////////////////////////////////////////////////////////////////////////////////
// This file illustrates how to use QCTraceSimulator for metrics calculation 
// of ControlledSWAP gates
///////////////////////////////////////////////////////////////////////////////////////////////////

namespace Microsoft.Quantum.Samples.UnitTesting
{
    public class ControlledSWAPMetrics
    {
        /// <summary>
        /// Interface provided by Xunit framework for logging during test execution.
        /// When the test is selected in Visual Studio Test Explore window 
        /// there is an Output text link available for each test. 
        /// </summary>
        private readonly Xunit.Abstractions.ITestOutputHelper output;

        public ControlledSWAPMetrics(Xunit.Abstractions.ITestOutputHelper output)
        {
            this.output = output;
        }

        // [Fact] attribute indicates that this function is a usual Xunit test
        [Fact(DisplayName = "ControlledSWAPMetrics")]
        public void ControlledSWAPMetricsTest()
        {
            // Get an instance of the appropriately configured QCTraceSimulator
            QCTraceSimulator sim = MetricCalculationUtils.GetSimulatorForMetricsCalculation();

            // Run tests against trace simulator to collect metrics
            var result = ControlledSWAPTest.Run(sim).Result;

            // Let us check that number of T gates in all the circuits is as expected
            string Tcount = PrimitiveOperationsGroupsNames.T;
            Assert.Equal(7, sim.GetMetric<ControlledSWAP1, CollectMetrics>(Tcount));
            Assert.Equal(7, sim.GetMetric<ControlledSWAPUsingCCNOT, CollectMetrics>(Tcount));

            // Let us check the number of CNOT gates 
            Assert.Equal(8, sim.GetMetric<ControlledSWAP1, CollectMetrics>(
                PrimitiveOperationsGroupsNames.CNOT));
            // Number of single qubit Clifford gates
            Assert.Equal(2, sim.GetMetric<ControlledSWAP1, CollectMetrics>(
                PrimitiveOperationsGroupsNames.QubitClifford));

            // And T depth
            Assert.Equal(4, sim.GetMetric<ControlledSWAP1, CollectMetrics>(
                MetricsNames.DepthCounter.Depth));

        }
    }
}
