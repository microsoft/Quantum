using System;
using System.Linq;
using System.Collections.Generic;

using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.Simulators {
    public class FlameGraphResourcesEstimator : ResourcesEstimator {
        private FlameGraphCounter operationsCounter;
        public static new QCTraceSimulatorConfiguration RecommendedConfig() =>
            new QCTraceSimulatorConfiguration
            {
                CallStackDepthLimit = Int32.MaxValue,

                ThrowOnUnconstrainedMeasurement = false,
                UseDistinctInputsChecker = false,
                UseInvalidatedQubitsUseChecker = false,

                UsePrimitiveOperationsCounter = false,
                UseDepthCounter = true,
                UseWidthCounter = true
            };

        public FlameGraphResourcesEstimator() : this(RecommendedConfig(), (int) PrimitiveOperationsGroups.CNOT) {}
        public FlameGraphResourcesEstimator(QCTraceSimulatorConfiguration config, int resourceToVisualize) : base(WithoutPrimitiveOperationsCounter(config)) {
            this.operationsCounter.resourceToVisualize = resourceToVisualize;
        }

        private static QCTraceSimulatorConfiguration WithoutPrimitiveOperationsCounter(QCTraceSimulatorConfiguration config) {
            config.UsePrimitiveOperationsCounter = false;
            return config;
        }
 
        protected override void InitializeQCTracerCoreListeners(IList<IQCTraceSimulatorListener> listeners) {
            base.InitializeQCTracerCoreListeners(listeners);
            var primitiveOperationsIdToNames = new Dictionary<int, string>();
            Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Utils.FillDictionaryForEnumNames<PrimitiveOperationsGroups, int>(primitiveOperationsIdToNames);
            var cfg = new PrimitiveOperationsCounterConfiguration {
                primitiveOperationsNames = primitiveOperationsIdToNames.Values.ToArray()
            };
            operationsCounter = new FlameGraphCounter(cfg);
            this.tCoreConfig.Listeners.Add(operationsCounter);
        }

        public Dictionary<string, double> GetFlameGraphData() =>
            operationsCounter.GetFlameGraphData();
        
    }
}
