// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using Microsoft.Quantum.Simulation.Core;

namespace ExecutionPathTracer
{
    /// <summary>
    /// Represents the qubit resources and operations traced out in an execution path of a Q# operation.
    /// </summary>
    public class ExecutionPath
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ExecutionPathTracer"/> class.
        /// </summary>
        /// <param name="qubits">
        /// A list of <see cref="QubitDeclaration"/> that represents the declared qubits used in the execution path.
        /// </param>
        /// <param name="operations">
        /// A list of <see cref="Operation"/> that represents the operations used in the execution path.
        /// </param>
        public ExecutionPath(IEnumerable<QubitDeclaration> qubits, IEnumerable<Operation> operations)
        {
            this.Qubits = qubits;
            this.Operations = operations;
        }

        /// <summary>
        /// A list of <see cref="QubitDeclaration"/> that represents the declared qubits used in the execution path.
        /// </summary>
        [JsonProperty("qubits")]
        public IEnumerable<QubitDeclaration> Qubits { get; }

        /// <summary>
        /// A list of <see cref="Operation"/> that represents the operations used in the execution path.
        /// </summary>
        [JsonProperty("operations")]
        public IEnumerable<Operation> Operations { get; }

        /// <summary>
        /// Serializes <see cref="ExecutionPath"/> into its JSON representation.
        /// </summary>
        /// <param name="prettyPrint">
        /// Pretty prints the JSON (i.e. with white space and indents) if <c>true</c>.
        /// </param>
        public string ToJson(bool prettyPrint = false) =>
            JsonConvert.SerializeObject(this,
                (prettyPrint) ? Formatting.Indented : Formatting.None,
                new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                }
            );
    }

    /// <summary>
    /// Represents a qubit resource used in an execution path.
    /// </summary>
    public class QubitDeclaration
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="QubitDeclaration"/> class.
        /// </summary>
        /// <param name="id">
        /// Id of qubit.
        /// </param>
        /// <param name="numChildren">
        /// Number of associated classical registers.
        /// </param>
        public QubitDeclaration(int id, int numChildren = 0)
        {
            this.Id = id;
            this.NumChildren = numChildren;
        }

        /// <summary>
        /// Id of qubit.
        /// </summary>
        [JsonProperty("id")]
        public int Id { get; }

        /// <summary>
        /// Number of associated classical registers.
        /// </summary>
        [JsonProperty("numChildren")]
        public int NumChildren { get; }

        /// <summary>
        /// Used by <see cref="Newtonsoft" /> to determine if <see cref="NumChildren" />
        /// should be included in the JSON serialization.
        /// </summary>
        public bool ShouldSerializeNumChildren() => NumChildren > 0;
    }

    /// <summary>
    /// Represents an operation used in an execution path.
    /// </summary>
    public class Operation
    {
        /// <summary>
        /// Label of gate.
        /// </summary>
        [JsonProperty("gate")]
        public string Gate { get; set; } = "";

        /// <summary>
        /// Arguments (except <see cref="Qubit" /> types) provided to gate that
        /// will be displayed by the visualizer.
        /// </summary>
        [JsonProperty("displayArgs")]
        public string? DisplayArgs { get; set; }

        /// <summary>
        /// Nested operations within this operation.
        /// </summary>
        [JsonProperty("children")]
        public IEnumerable<Operation>? Children { get; set; }

        /// <summary>
        /// True if operation is a measurement operations.
        /// </summary>
        [JsonProperty("isMeasurement")]
        public bool IsMeasurement { get; set; }

        /// <summary>
        /// True if operation is a controlled operations.
        /// </summary>
        [JsonProperty("isControlled")]
        public bool IsControlled { get; set; }

        /// <summary>
        /// True if operation is an adjoint operations.
        /// </summary>
        [JsonProperty("isAdjoint")]
        public bool IsAdjoint { get; set; }

        /// <summary>
        /// List of control registers.
        /// </summary>
        [JsonProperty("controls")]
        public IEnumerable<Register> Controls { get; set; } = new List<Register>();

        /// <summary>
        /// List of target registers.
        /// </summary>
        [JsonProperty("targets")]
        public IEnumerable<Register> Targets { get; set; } = new List<Register>();

        /// <summary>
        /// Dictionary of data attributes to add to rendered gate element.
        /// </summary>
        [JsonProperty("dataAttributes")]
        public IDictionary<string, string> DataAttributes = new Dictionary<string, string>();
    }
}
