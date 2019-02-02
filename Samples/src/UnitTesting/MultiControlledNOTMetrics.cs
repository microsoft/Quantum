// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using Xunit;

///////////////////////////////////////////////////////////////////////////////////////////////////
// This file illustrates how to use QCTraceSimulator for metrics calculation 
// Multiply Controlled Not gates
///////////////////////////////////////////////////////////////////////////////////////////////////

namespace Microsoft.Quantum.Samples.UnitTesting
{
    public class MultiControlledNOTMetrics
    {
        /// <summary>
        /// Interface provided by Xunit framework for logging during test execution.
        /// When the test is selected in Visual Studio Test Explore window 
        /// there is an Output text link available for each test. 
        /// </summary>
        private readonly Xunit.Abstractions.ITestOutputHelper output;

        public MultiControlledNOTMetrics(Xunit.Abstractions.ITestOutputHelper output)
        {
            this.output = output;
        }

        // [Theory] attribute lets developer create tests with parameters
        [Theory(DisplayName = "MultiControlledNOTMetrics")]
        [InlineData(4L)] // this is one of the way of specifying parameters 
        [InlineData(5L)] // for the theory. This test will be executed with 
        [InlineData(2017L)] // numberOfControlQubits = 4,5,2017
        public void MultiControlledNOTMetricsTest( long numberOfControlQubits )
        {
            // Get an instance of the appropriately configured QCTraceSimulator
            QCTraceSimulator sim = MetricCalculationUtils.GetSimulatorForMetricsCalculation();

            // Run tests against trace simulator to collect metrics
            var result = 
                MultiControlledNotWithDirtyQubitsMetrics.Run(sim, numberOfControlQubits).Result;

            string borrowedQubits = MetricsNames.WidthCounter.BorrowedWith;
            string allocatedQubits = MetricsNames.WidthCounter.ExtraWidth;

            // Get the number of qubits borrowed by the MultiControlledXBorrow
            double numBorrowed1 = 
                sim.GetMetric<MultiControlledXBorrow, MultiControlledNotWithDirtyQubitsMetrics>(
                    borrowedQubits);

            // Get the number of qubits allocated by the MultiControlledXBorrow
                double numAllocated1 =
                sim.GetMetric<MultiControlledXBorrow, MultiControlledNotWithDirtyQubitsMetrics>(
                    allocatedQubits);

            Assert.Equal(numberOfControlQubits - 2, numBorrowed1);
            Assert.Equal(0, numAllocated1);

            // Get the number of qubits borrowed by the MultiControlledXClean
            double numBorrowed2 =
                sim.GetMetric<MultiControlledXClean, MultiControlledNotWithDirtyQubitsMetrics>(
                    borrowedQubits);

            // Get the number of qubits allocated by the MultiControlledXClean
            double numAllocated2 =
            sim.GetMetric<MultiControlledXClean, MultiControlledNotWithDirtyQubitsMetrics>(
                allocatedQubits);

            Assert.Equal(numberOfControlQubits - 2, numAllocated2);
            Assert.Equal(0, numBorrowed2);
        }
    }
}
