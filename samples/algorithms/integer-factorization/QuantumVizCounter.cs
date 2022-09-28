// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System.Collections.Generic;
using System.Diagnostics;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

using Newtonsoft.Json;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    /// <summary>
    /// Special listener to generate quantum-viz.js circuit with resources information.
    /// </summary>
    public class QuantumVizCounter : IQCTraceSimulatorListener
    {
        // This stack tracks all operations currently on the call stack, the
        // most recent one on the top.
        private readonly Stack<Operation> callStack = new Stack<Operation>();

        /// <summary>
        /// Returns the quantum-viz.js circuit, that can be serialized to valid
        /// JSON output.
        /// </summary>
        public Circuit Circuit { get; } = new Circuit();

        public QuantumVizCounter(PrimitiveOperationsCounterConfiguration config)
        {
            // Place the root call onto the stack.  This operation will not end
            // and still be on the stack once the simulator has run the Q# entry
            // point operation.
            var operation = new Operation { Gate = CallGraphEdge.CallGraphRootHashed };
            Circuit.Operations.Add(operation);
            callStack.Push(operation);
        }

        #region ITracingSimulatorListener implementation
        /// <summary>
        /// A primitive operation call causes an update of the corresponding
        /// counter of the operation call on the top of the call stack.
        /// </summary>
        public void OnPrimitiveOperation(int id, object[] qubitsTraceData, double duration)
        {
            switch (id)
            {
                case (int)PrimitiveOperationsGroups.CNOT:
                    callStack.Peek().CNOTCount += 1.0;
                    break;
                case (int)PrimitiveOperationsGroups.QubitClifford:
                    callStack.Peek().CliffordCount += 1.0;
                    break;
                case (int)PrimitiveOperationsGroups.R:
                    callStack.Peek().RCount += 1.0;
                    break;
                case (int)PrimitiveOperationsGroups.T:
                    callStack.Peek().TCount += 1.0;
                    break;
            }
        }

        /// <summary>
        /// With the start of a new operation call, a new entry is added to the
        /// operation call stack.  Also we read the affected qubits from the
        /// <c>qubitsTraceData</c> argument.
        /// </summary>
        public void OnOperationStart(HashedString name, OperationFunctor variant, object[] qubitsTraceData)
        {
            var operation = new Operation { Gate = name };
            foreach (var qubit in qubitsTraceData)
            {
                operation.Targets.Add((QubitReference)qubit);
            }
            operation.IsAdjoint = variant == OperationFunctor.Adjoint || variant == OperationFunctor.ControlledAdjoint;
            callStack.Push(operation);
        }
        
        /// <summary>
        /// When the operation ends, it's popped from the stack and added as
        /// child to the next top-most operation on the stack.
        /// </summary>
        public void OnOperationEnd(object[] returnedQubitsTraceData)
        {
            var lastOperation = callStack.Pop();
            Debug.Assert(callStack.Count != 0, "Operation call stack must never get empty");

            // Add operation to parent and also update qubits
            callStack.Peek().AddChild(lastOperation);
        }

        /// <summary>
        /// Adds an outer interface qubit to the circuit data structure, whenever
        /// a new qubit is allocated.
        /// </summary>
        public void OnAllocate(object[] qubitsTraceData)
        {
            foreach (var qubit in qubitsTraceData)
            {
                Circuit.Qubits.Add(new Qubit { Id = ((QubitReference)qubit).Id });
            }
        }

        public void OnRelease(object[] qubitsTraceData) {}

        public void OnBorrow(object[] qubitsTraceData, long newQubitsAllocated) {}

        public void OnReturn(object[] qubitsTraceData, long newQubitsAllocated) {}

        /// <summary>
        /// Tracing data is captured in the custom qubit type using the qubit's id.
        /// </summary>
        public object? NewTracingData(long qubitId) => new QubitReference { Id = qubitId };

        /// <summary>
        /// This ensures that the listener traces qubit data.
        /// </summary>
        public bool NeedsTracingDataInQubits => true;
        #endregion
    }

    public class Circuit {
        [JsonProperty(PropertyName = "qubits")]
        public HashSet<Qubit> Qubits { get; set; } = new HashSet<Qubit>();
        [JsonProperty(PropertyName = "operations")]
        public List<Operation> Operations { get; set; } = new List<Operation>();
    }

    public class Operation {
        [JsonProperty(PropertyName = "gate")]
        public string Gate { get; set; } = string.Empty;
        [JsonProperty(PropertyName = "displayArgs")]
        public string DisplayArgs { get => $"CNOT: {CNOTCount} Clifford: {CliffordCount} R: {RCount} T: {TCount}"; }
        [JsonProperty(PropertyName = "children")]
        public List<Operation> Children { get; set; } = new List<Operation>();
        [JsonProperty(PropertyName = "targets")]
        public HashSet<QubitReference> Targets { get; set; } = new HashSet<QubitReference>();
        [JsonProperty(PropertyName = "isAdjoint")]
        public bool IsAdjoint { get; set; } = false;

        // We're not outputting the resource count fields in the JSON, since we
        // include them in DisplayArgs field
        [JsonIgnore]
        public double CNOTCount { get; set; } = 0.0;
        [JsonIgnore]
        public double CliffordCount { get; set; } = 0.0;
        [JsonIgnore]
        public double RCount { get; set; } = 0.0;
        [JsonIgnore]
        public double TCount { get; set; } = 0.0;

        /// <summary>
        /// Adds operation and updates counters and targets
        /// </summary>
        public void AddChild(Operation child)
        {
            Children.Add(child);
            CNOTCount += child.CNOTCount;
            CliffordCount += child.CliffordCount;
            RCount += child.RCount;
            TCount += child.TCount;

            foreach (var target in child.Targets)
            {
                Targets.Add(target);
            }
        }
    }

    public class Qubit {
        [JsonProperty(PropertyName = "id")]
        public long Id { get; set; } = 0;

        public override bool Equals(object? obj)
        {
            return (obj != null) && ((Qubit)obj).Id == Id;
        }

        public override int GetHashCode()
        {
            return Id.GetHashCode();
        }
    }

    public class QubitReference {
        [JsonProperty(PropertyName = "qId")]

        public long Id { get; set; } = 0;

        public override bool Equals(object? obj)
        {
            return (obj != null) && ((QubitReference)obj).Id == Id;
        }

        public override int GetHashCode()
        {
            return Id.GetHashCode();
        }
    }
}
