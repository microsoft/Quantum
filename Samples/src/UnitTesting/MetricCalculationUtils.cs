// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Samples.UnitTesting
{
    static class MetricCalculationUtils
    {
        /// <summary>
        /// Returns an instance of QCTraceSimulator configured to collect 
        /// circuit metrics
        /// </summary>
        public static QCTraceSimulator GetSimulatorForMetricsCalculation()
        {
            // Setup QCTraceSimulator to collect all available metrics
            var config = new QCTraceSimulatorConfiguration
            {
                UseDepthCounter = true,
                UsePrimitiveOperationsCounter = true,
                UseWidthCounter = true
            };

            // Set up gate times to compute T depth
            config.TraceGateTimes[PrimitiveOperationsGroups.CNOT] = 0;
            config.TraceGateTimes[PrimitiveOperationsGroups.QubitClifford] = 0;
            config.TraceGateTimes[PrimitiveOperationsGroups.Measure] = 0;
            config.TraceGateTimes[PrimitiveOperationsGroups.R] = 0;
            config.TraceGateTimes[PrimitiveOperationsGroups.T] = 1;

            // Create an instance of Quantum Computer Trace Simulator
            return new QCTraceSimulator(config);
        }
    }
}
