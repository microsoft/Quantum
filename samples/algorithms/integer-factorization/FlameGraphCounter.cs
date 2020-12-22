using System.Collections.Generic;
using System.Diagnostics;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime {
    public class FlameGraphCounter : IQCTraceSimulatorListener, ICallGraphStatistics {
        class OperationCallRecord
        {
            public HashedString OperationName;
            public OperationFunctor FunctorSpecialization;
            public double[] GlobalCountersAtOperationStart;
        }

        private readonly PrimitiveOperationsCounterConfiguration configuration;

        /// <summary>
        /// Number of Primitive operations performed since the beginning of the execution.
        /// Double type is used because all the collected statistics are of type double.
        /// </summary>
        private readonly double[] globalCounters;
        private readonly Stack<OperationCallRecord> operationCallStack;
        private Dictionary<string, double> flameGraphData;
        private string callStack = "";
        public int resourceToVisualize {get; set;} = (int) PrimitiveOperationsGroups.CNOT;
        private readonly int PrimitiveOperationsCount;
        private readonly StatisticsCollector<CallGraphEdge> stats;
        public PrimitiveOperationsCounterConfiguration GetConfigurationCopy() { return Utils.DeepClone(configuration); }
        public IStatisticCollectorResults<CallGraphEdge> Results { get => stats as IStatisticCollectorResults<CallGraphEdge>; }

        /// <param name="statisticsToCollect">
        /// Statistics to be collected. If set to null, the
        /// statistics returned by <see cref="StatisticsCollector.DefaultStatistics"/>
        /// are used. </param>
        public FlameGraphCounter(PrimitiveOperationsCounterConfiguration config, IDoubleStatistic[]  statisticsToCollect = null )
        {
            configuration = Utils.DeepClone(config);
            PrimitiveOperationsCount = configuration.primitiveOperationsNames.Length;
            globalCounters = new double[PrimitiveOperationsCount];
            operationCallStack = new Stack<OperationCallRecord>();
            AddToCallStack(CallGraphEdge.CallGraphRootHashed,OperationFunctor.Body);
            stats = new StatisticsCollector<CallGraphEdge>(
                config.primitiveOperationsNames,
                statisticsToCollect ?? StatisticsCollector<CallGraphEdge>.DefaultStatistics()
                );
            this.flameGraphData = new Dictionary<string, double>();
        }

        public Dictionary<string, double> GetFlameGraphData() {
            return new Dictionary<string, double>(this.flameGraphData);
        }

        // returns the resulting call stack after adding the given function call
        private static string pushString(string s, string add) {
            Debug.Assert(s != null);
            Debug.Assert(add != null);
            return s.Length == 0 ? add : s + ";" + add;
        }

        // returns the remaining string after popping a function call from the stack
        private static string popString(string s) {
            int index = s.LastIndexOf(';');
            return index > 0 ? s.Substring(0, index) : "";
        }

        private void AddToCallStack( HashedString operationName, OperationFunctor functorSpecialization)
        {
            operationCallStack.Push(
                new OperationCallRecord()
                {
                    GlobalCountersAtOperationStart = new double[PrimitiveOperationsCount],
                    OperationName = operationName,
                    FunctorSpecialization = functorSpecialization
                });
            globalCounters.CopyTo(operationCallStack.Peek().GlobalCountersAtOperationStart, 0);
            callStack = pushString(callStack, operationName);
        }

        #region ITracingSimulatorListener implementation
        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnAllocate(object[] qubitsTraceData)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnRelease(object[] qubitsTraceData)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnBorrow(object[] qubitsTraceData, long newQubitsAllocated)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnReturn(object[] qubitsTraceData, long newQubitsAllocated)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnPrimitiveOperation(int id, object[] qubitsTraceData, double PrimitiveOperationDuration)
        {
            Debug.Assert(id < PrimitiveOperationsCount);
            globalCounters[id] += 1.0;
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnOperationStart(HashedString name, OperationFunctor variant, object[] qubitsTraceData)
        {
            AddToCallStack(name,variant);
        }
        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnOperationEnd(object[] returnedQubitsTraceData)
        {
            OperationCallRecord record = operationCallStack.Pop();
            Debug.Assert(operationCallStack.Count != 0, "Operation call stack must never get empty");
            double[] difference = Utils.ArrayDifference(globalCounters, record.GlobalCountersAtOperationStart);
            stats.AddSample(
                new CallGraphEdge(
                    record.OperationName,
                    operationCallStack.Peek().OperationName,
                    record.FunctorSpecialization,
                    operationCallStack.Peek().FunctorSpecialization),
                difference
                );
            record.GlobalCountersAtOperationStart.CopyTo(globalCounters, 0);
            if (flameGraphData.ContainsKey(callStack))
                flameGraphData[callStack] += difference[this.resourceToVisualize];
            else
                flameGraphData.Add(callStack, difference[this.resourceToVisualize]);
            callStack = popString(callStack);
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public object NewTracingData(long qubitId)
        {
            return null;
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public bool NeedsTracingDataInQubits => false;
        #endregion
    }
}