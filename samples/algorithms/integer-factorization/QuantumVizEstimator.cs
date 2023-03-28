// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Linq;
using System.Collections.Generic;

using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public class QuantumVizEstimator : QCTraceSimulator
    {
        private QuantumVizCounter? operationsCounter;
        public static QCTraceSimulatorConfiguration RecommendedConfig() =>
            new QCTraceSimulatorConfiguration
            {
                CallStackDepthLimit = 4,

                ThrowOnUnconstrainedMeasurement = false,
                UseDistinctInputsChecker = false,
                UseInvalidatedQubitsUseChecker = false,

                UsePrimitiveOperationsCounter = false,
                UseDepthCounter = true,
                UseWidthCounter = true
            };

        public QuantumVizEstimator() : this(RecommendedConfig()) {}
        public QuantumVizEstimator(QCTraceSimulatorConfiguration config) : base(WithoutPrimitiveOperationsCounter(config))
        {
        }

        private static QCTraceSimulatorConfiguration WithoutPrimitiveOperationsCounter(QCTraceSimulatorConfiguration config)
        {
            config.UsePrimitiveOperationsCounter = false;
            return config;
        }
 
        protected override void InitializeQCTracerCoreListeners(IList<IQCTraceSimulatorListener> listeners)
        {
            base.InitializeQCTracerCoreListeners(listeners);
            var primitiveOperationsIdToNames = new Dictionary<int, string>();
            Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Utils.FillDictionaryForEnumNames<PrimitiveOperationsGroups, int>(primitiveOperationsIdToNames);
            var cfg = new PrimitiveOperationsCounterConfiguration {
                primitiveOperationsNames = primitiveOperationsIdToNames.Values.ToArray()
            };
            operationsCounter = new QuantumVizCounter(cfg);
            this.tCoreConfig.Listeners.Add(operationsCounter);
        }

        // We can guarantee that <c>operationsCounter</c> is not null, because
        // <c>InitializeQCTracerCoreListeners</c> is called by the constructor.
        public Circuit Circuit => operationsCounter!.Circuit;
    }
}
