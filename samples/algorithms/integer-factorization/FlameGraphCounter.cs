using System.Collections.Generic;
using System.Diagnostics;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime {
    public class FlameGraphCounter : IQCTraceSimulatorListener {
        private readonly PrimitiveOperationsCounterConfiguration configuration;
        
        /// <summary>
        /// Contains all fully specified calls including resource count for the operation excluding all children.
        /// </summary>
        public Dictionary<string, double> FlameGraphData { get; } = new Dictionary<string, double>();

        /// <summary>
        /// Sets which resource to track (e.g., CNOT)
        /// </summary>
        public PrimitiveOperationsGroups ResourceToVisualize { get; set; } = PrimitiveOperationsGroups.CNOT;

        /// <summary>
        /// Number of Primitive operations performed since the beginning of the execution.
        /// Double type is used because all the collected statistics are of type double.
        /// </summary>
        private readonly double[] globalCounters;

        private readonly Stack<double[]> operationCallStack;

        private string callStack = "";

        /// <param name="statisticsToCollect">
        /// Statistics to be collected. If set to null, the
        /// statistics returned by <see cref="StatisticsCollector.DefaultStatistics"/>
        /// are used. </param>
        public FlameGraphCounter(PrimitiveOperationsCounterConfiguration config, IDoubleStatistic[]  statisticsToCollect = null )
        {
            configuration = Utils.DeepClone(config);
            globalCounters = new double[configuration.primitiveOperationsNames.Length];
            operationCallStack = new Stack<double[]>();
            AddToCallStack(CallGraphEdge.CallGraphRootHashed,OperationFunctor.Body);
        }

        // returns the resulting call stack after adding the given function call
        private static string PushString(string s, string add)
        {
            Debug.Assert(s != null);
            Debug.Assert(add != null);
            return s.Length == 0 ? add : s + ";" + add;
        }

        // returns the remaining call stack after removing a function call from the top of the stack
        private static string PopString(string s)
        {
            int index = s.LastIndexOf(';');
            return index > 0 ? s.Substring(0, index) : "";
        }

        private void AddToCallStack( HashedString operationName, OperationFunctor functorSpecialization)
        {
            operationCallStack.Push(new double[globalCounters.Length]);
            globalCounters.CopyTo(operationCallStack.Peek(), 0);
            callStack = PushString(callStack, operationName);
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
            Debug.Assert(id < globalCounters.Length);
            globalCounters[id] += 1.0;
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnOperationStart(HashedString name, OperationFunctor variant, object[] qubitsTraceData)
        {
            AddToCallStack(name, variant);
        }
        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnOperationEnd(object[] returnedQubitsTraceData)
        {
            var globalCountersAtOperationStart = operationCallStack.Pop();
            Debug.Assert(operationCallStack.Count != 0, "Operation call stack must never get empty");
            double[] difference = Utils.ArrayDifference(globalCounters, globalCountersAtOperationStart);
            globalCountersAtOperationStart.CopyTo(globalCounters, 0);
            if (FlameGraphData.ContainsKey(callStack))
                FlameGraphData[callStack] += difference[(int)ResourceToVisualize];
            else
                FlameGraphData.Add(callStack, difference[(int)ResourceToVisualize]);
            callStack = PopString(callStack);
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public object NewTracingData(long qubitId) => null;

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public bool NeedsTracingDataInQubits => false;
        #endregion
    }
}
