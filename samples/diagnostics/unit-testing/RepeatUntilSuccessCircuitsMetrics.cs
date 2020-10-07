// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using Xunit;

// We can use C# type aliases to shorten long caller names
using caller = Microsoft.Quantum.Canon.ApplyToFirstQubit;

///////////////////////////////////////////////////////////////////////////////////////////////////
// This file illustrates how to use QCTraceSimulator for metrics calculation 
// of Repeat Until Success circuits
///////////////////////////////////////////////////////////////////////////////////////////////////

namespace Microsoft.Quantum.Samples.UnitTesting
{
    public class RepeatUntilSuccessCircuitsMetrics
    {
        /// <summary>
        /// Interface provided by Xunit framework for logging during test execution.
        /// When the test is selected in Visual Studio Test Explore window 
        /// there is an Output text link available for each test. 
        /// </summary>
        private readonly Xunit.Abstractions.ITestOutputHelper output;

        public RepeatUntilSuccessCircuitsMetrics(Xunit.Abstractions.ITestOutputHelper output)
        {
            this.output = output;
        }

        // [Fact] attribute indicates that this function is a usual Xunit test
        [Fact(DisplayName = "RepeatUntilSuccessCircuitsMetrics")]
        public void RepeatUntilSuccessCircuitsMetricsTest()
        {
            // Get an instance of the appropriately configured QCTraceSimulator
            var sim = MetricCalculationUtils.GetSimulatorForMetricsCalculation();

            // Run tests against trace simulator to collect metrics
            var result = CheckRepeatUntilSuccessRotatesByCorrectAngle.Run(sim).Result;

            var TCount = PrimitiveOperationsGroupsNames.T;
            var extraQubits = MetricsNames.WidthCounter.ExtraWidth;
            var min = StatisticsNames.Min;
            var max = StatisticsNames.Max;
            var avg = StatisticsNames.Average;

            // Let us check how many auxiliary qubits we used
            // 4 for Nielsen & Chuang
            // version because we used CCNOT3 which itself required 2 auxiliary
            Assert.Equal(4, sim.GetMetric<ExpIZArcTan2NC, caller>(extraQubits));
            // 2 for Paetznick & Svore version 
            Assert.Equal(2, sim.GetMetric<ExpIZArcTan2PS, caller>(extraQubits));

            // One trial of ExpIZArcTan2NC requires at least 8 T gates
            Assert.True(8 <= sim.GetMetricStatistic<ExpIZArcTan2NC, caller>(TCount,min));

            // One trial of ExpIZArcTan2NC requires at least 3 T gates
            Assert.True(3 <= sim.GetMetricStatistic<ExpIZArcTan2PS, caller>(TCount, min));

            // The rest of the statistical information we print into test output
            // For ExpIZArcTan2NC:
            output.WriteLine($"Statistics collected for{nameof(ExpIZArcTan2NC)}");
            output.WriteLine($"Average number of T-gates:" +
                $" {sim.GetMetricStatistic<ExpIZArcTan2NC, caller>(TCount, avg)}");
            output.WriteLine($"Minimal number of T-gates: " +
                $"{sim.GetMetricStatistic<ExpIZArcTan2NC, caller>(TCount, min)}");
            output.WriteLine($"Maximal number of T-gates: " +
                $"{sim.GetMetricStatistic<ExpIZArcTan2NC, caller>(TCount, max)}");

            // And for ExpIZArcTan2PS
            output.WriteLine($"Statistics collected for{nameof(ExpIZArcTan2PS)}");
            output.WriteLine($"Average number of T-gates:" +
                $" {sim.GetMetricStatistic<ExpIZArcTan2PS, caller>(TCount, avg)}");
            output.WriteLine($"Minimal number of T-gates: " +
                $"{sim.GetMetricStatistic<ExpIZArcTan2PS, caller>(TCount, min)}");
            output.WriteLine($"Maximal number of T-gates: " +
                $"{sim.GetMetricStatistic<ExpIZArcTan2PS, caller>(TCount, max)}");

        }
    }
}
