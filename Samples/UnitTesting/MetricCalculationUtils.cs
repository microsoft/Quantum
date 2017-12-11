// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

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
                useDepthCounter = true,
                usePrimitiveOperationsCounter = true,
                useWidthCounter = true
            };

            // Set up gate times to compute T depth
            config.gateTimes[PrimitiveOperationsGroups.CNOT] = 0;
            config.gateTimes[PrimitiveOperationsGroups.QubitClifford] = 0;
            config.gateTimes[PrimitiveOperationsGroups.Measure] = 0;
            config.gateTimes[PrimitiveOperationsGroups.R] = 0;
            config.gateTimes[PrimitiveOperationsGroups.T] = 1;

            // Create an instance of Quantum Computer Trace Simulator
            return new QCTraceSimulator(config);
        }
    }
}
