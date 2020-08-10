// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;

#nullable enable

namespace ExecutionPathTracer
{
    /// <summary>
    /// Traces through the operations in a given execution path of a Q# program by hooking on
    /// to a simulator via the event listeners <see cref="OnOperationStartHandler"/> and
    /// <see cref="OnOperationEndHandler"/>, and generates the corresponding <see cref="ExecutionPath"/>.
    /// </summary>
    public class ExecutionPathTracer
    {
        private int currentDepth = 0;
        private int renderDepth;
        private ICallable? currCompositeOp = null;
        private ExecutionPathTracer? compositeTracer = null;
        private Operation? currentOperation = null;
        private IDictionary<int, QubitRegister> qubitRegisters = new Dictionary<int, QubitRegister>();
        private IDictionary<int, List<ClassicalRegister>> classicalRegisters = new Dictionary<int, List<ClassicalRegister>>();
        private List<Operation> operations = new List<Operation>();

        /// <summary>
        /// Initializes a new instance of the <see cref="ExecutionPathTracer"/> class with the depth to render operations at.
        /// </summary>
        /// <param name="depth">
        /// The depth at which to render operations.
        /// </param>
        public ExecutionPathTracer(int depth = 1) => this.renderDepth = depth + 1;

        /// <summary>
        /// Returns the generated <see cref="ExecutionPath"/>.
        /// </summary>
        public ExecutionPath GetExecutionPath() =>
            new ExecutionPath(
                this.qubitRegisters.Keys
                    .OrderBy(k => k)
                    .Select(k => new QubitDeclaration(k, (this.classicalRegisters.ContainsKey(k))
                        ? this.classicalRegisters[k].Count
                        : 0
                    )),
                this.operations
            );

        /// <summary>
        /// Provides the event listener to listen to
        /// <see cref="Microsoft.Quantum.Simulation.Common.SimulatorBase"/>'s
        /// <c>OnOperationStart</c> event.
        /// </summary>
        public void OnOperationStartHandler(ICallable operation, IApplyData arguments)
        {
            this.currentDepth++;

            // If `compositeTracer` is initialized, pass operations into it instead
            if (this.compositeTracer != null)
            {
                this.compositeTracer.OnOperationStartHandler(operation, arguments);
                return;
            }

            // Only parse operations at or above (i.e. <= `renderDepth`) specified depth
            if (this.currentDepth > this.renderDepth) return;

            var metadata = operation.GetRuntimeMetadata(arguments);

            // If metadata is a composite operation (i.e. want to trace its components instead),
            // we recursively create a tracer that traces its components instead
            if (metadata != null && metadata.IsComposite)
            {
                var remainingDepth = this.renderDepth - this.currentDepth;
                this.compositeTracer = new ExecutionPathTracer(remainingDepth);
                // Attach our registers by reference to compositeTracer
                this.compositeTracer.qubitRegisters = this.qubitRegisters;
                this.compositeTracer.classicalRegisters = this.classicalRegisters;
                this.currCompositeOp = operation;
                // Set currentOperation to null so we don't render higher-depth operations unintentionally.
                this.currentOperation = null;
                return;
            }

            // Save parsed operation as a potential candidate for rendering.
            // We only want to render the operation at the lowest depth, so we keep
            // a running track of the lowest operation seen in the stack thus far.
            this.currentOperation = this.MetadataToOperation(metadata);
        }

        /// <summary>
        /// Provides the event listener to listen to
        /// <see cref="Microsoft.Quantum.Simulation.Common.SimulatorBase"/>'s
        /// <c>OnOperationEnd</c> event.
        /// </summary>
        public void OnOperationEndHandler(ICallable operation, IApplyData result)
        {
            this.currentDepth--;

            // If `compositeTracer` is not null, handle the incoming operation recursively.
            if (this.compositeTracer != null)
            {
                // If the current operation is the composite operation we started with, append
                // the operations traced out by the `compositeTracer` to the current list of
                // operations and reset.
                if (operation == this.currCompositeOp)
                {
                    this.AddCompositeOperations();
                    this.currCompositeOp = null;
                    this.compositeTracer = null;
                    return;
                }

                // Pass operations down to it for handling
                this.compositeTracer.OnOperationEndHandler(operation, result);
                return;
            }

            // Add latest parsed operation to list of operations, if not null
            if (this.currentOperation != null)
            {
                this.operations.Add(this.currentOperation);
                this.currentOperation = null;
            }
        }

        /// <summary>
        /// Retrieves the <see cref="QubitRegister"/> associated with the given <see cref="Qubit"/> or create a new
        /// one if it doesn't exist.
        /// </summary>
        private QubitRegister GetQubitRegister(Qubit qubit) =>
            this.qubitRegisters.GetOrCreate(qubit.Id, new QubitRegister(qubit.Id));

        private List<QubitRegister> GetQubitRegisters(IEnumerable<Qubit> qubits) =>
            qubits.Select(this.GetQubitRegister).ToList();

        /// <summary>
        /// Creates a new <see cref="ClassicalRegister"/> and associate it with the given <see cref="Qubit"/>.
        /// </summary>
        private ClassicalRegister CreateClassicalRegister(Qubit measureQubit)
        {
            var qId = measureQubit.Id;
            var cId = this.classicalRegisters.GetOrCreate(qId).Count;

            var register = new ClassicalRegister(qId, cId);

            // Add classical register under the given qubit id
            this.classicalRegisters[qId].Add(register);

            return register;
        }

        /// <summary>
        /// Retrieves the most recent <see cref="ClassicalRegister"/> associated with the given <see cref="Qubit"/>.
        /// </summary>
        /// <remarks>
        /// Currently not used as this is intended for classically-controlled operations.
        /// </remarks>
        private ClassicalRegister GetClassicalRegister(Qubit controlQubit)
        {
            var qId = controlQubit.Id;
            if (!this.classicalRegisters.ContainsKey(qId) || this.classicalRegisters[qId].Count == 0)
            {
                throw new Exception("No classical registers found for qubit {qId}.");
            }

            // Get most recent measurement on given control qubit
            var cId = this.classicalRegisters[qId].Count - 1;
            return this.classicalRegisters[qId][cId];
        }

        /// <summary>
        /// Parse <see cref="Operation"/>s traced out by the <c>compositeTracer</c>.
        /// </summary>
        private void AddCompositeOperations()
        {
            if (this.compositeTracer == null)
                throw new NullReferenceException("ERROR: compositeTracer not initialized.");

            // The composite tracer has done its job and we retrieve the operations it traced
            this.operations.AddRange(this.compositeTracer.operations);
        }

        /// <summary>
        /// Parse <see cref="RuntimeMetadata"/> into its corresponding <see cref="Operation"/>.
        /// </summary>
        private Operation? MetadataToOperation(RuntimeMetadata? metadata)
        {
            if (metadata == null) return null;

            var displayArgs = (metadata.FormattedNonQubitArgs.Length > 0)
                ? metadata.FormattedNonQubitArgs
                : null;

            // Add surrounding parentheses around displayArgs if it doesn't already have it (i.e. not a tuple)
            if (displayArgs != null && !displayArgs.StartsWith("(")) displayArgs = $"({displayArgs})";

            var op = new Operation()
            {
                Gate = metadata.Label,
                DisplayArgs = displayArgs,
                Children = metadata.Children?.Select(child => child.Select(this.MetadataToOperation).WhereNotNull()),
                IsControlled = metadata.IsControlled,
                IsAdjoint = metadata.IsAdjoint,
                Controls = this.GetQubitRegisters(metadata.Controls),
                Targets = this.GetQubitRegisters(metadata.Targets),
            };

            // Create classical registers for measurement operations
            if (metadata.IsMeasurement)
            {
                var measureQubit = metadata.Targets.ElementAt(0);
                var clsReg = this.CreateClassicalRegister(measureQubit);
                op.IsMeasurement = true;
                op.Controls = op.Targets;
                op.Targets = new List<Register>() { clsReg };
            }

            return op;
        }
    }
}
