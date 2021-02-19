using System.Collections.Generic;
using System.Diagnostics;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
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

        private readonly Stack<double[]> operationCallStack = new Stack<double[]>();

        private string callStack = string.Empty;

        public FlameGraphCounter(PrimitiveOperationsCounterConfiguration config)
        {
            configuration = Utils.DeepClone(config);
            globalCounters = new double[configuration.primitiveOperationsNames.Length];
            AddToCallStack(CallGraphEdge.CallGraphRootHashed, OperationFunctor.Body);
        }

        // returns the resulting call stack after adding the given function call
        private static string PushString(string s, string add)
        {
            Debug.Assert(s != null);
            Debug.Assert(add != null);
            return string.IsNullOrEmpty(s) ? add : s + ";" + add;
        }

        // returns the remaining call stack after removing a function call from the top of the stack
        private static string PopString(string s)
        {
            int index = s.LastIndexOf(';');
            return index > 0 ? s.Substring(0, index) : "";
        }

        private void AddToCallStack(HashedString operationName, OperationFunctor functorSpecialization)
        {
            operationCallStack.Push(new double[globalCounters.Length]);
            globalCounters.CopyTo(operationCallStack.Peek(), 0);
            callStack = PushString(callStack, operationName);
        }

        #region ITracingSimulatorListener implementation
        public void OnPrimitiveOperation(int id, object[] qubitsTraceData, double PrimitiveOperationDuration)
        {
            Debug.Assert(id < globalCounters.Length);
            globalCounters[id] += 1.0;
        }

        public void OnOperationStart(HashedString name, OperationFunctor variant, object[] qubitsTraceData)
        {
            AddToCallStack(name, variant);
        }
        
        public void OnOperationEnd(object[] returnedQubitsTraceData)
        {
            var globalCountersAtOperationStart = operationCallStack.Pop();
            Debug.Assert(operationCallStack.Count != 0, "Operation call stack must never get empty");
            double[] difference = Utils.ArrayDifference(globalCounters, globalCountersAtOperationStart);
            globalCountersAtOperationStart.CopyTo(globalCounters, 0);
            if (FlameGraphData.ContainsKey(callStack))
            {
                FlameGraphData[callStack] += difference[(int)ResourceToVisualize];
            }
            else
            {
                FlameGraphData.Add(callStack, difference[(int)ResourceToVisualize]);
            }
            callStack = PopString(callStack);
        }

        public void OnAllocate(object[] qubitsTraceData) {}

        public void OnRelease(object[] qubitsTraceData) {}

        public void OnBorrow(object[] qubitsTraceData, long newQubitsAllocated) {}

        public void OnReturn(object[] qubitsTraceData, long newQubitsAllocated) {}

        public object NewTracingData(long qubitId) => null;

        public bool NeedsTracingDataInQubits => false;
        #endregion
    }
}
