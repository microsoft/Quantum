// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace ExecutionPathTracer
{
    /// <summary>
    /// Enum for the 2 types of registers: <c>Qubit</c> and <c>Classical</c>.
    /// </summary>
    public enum RegisterType
    {
        /// <summary>
        /// Qubit register that holds a qubit.
        /// </summary>
        Qubit,
        /// <summary>
        /// Classical register that holds a classical bit.
        /// </summary>
        Classical,
    }

    /// <summary>
    /// Represents a register used by an <see cref="Operation"/>.
    /// </summary>
    public class Register
    {
        /// <summary>
        /// Type of register.
        /// </summary>
        [JsonProperty("type")]
        public virtual RegisterType Type { get; }

        /// <summary>
        /// Qubit id of register.
        /// </summary>
        [JsonProperty("qId")]
        public virtual int QId { get; protected set; }

        /// <summary>
        /// Classical bit id of register. <c>null</c> if register is a qubit register.
        /// </summary>
        [JsonProperty("cId")]
        public virtual int? CId { get; protected set; }
    }

    /// <summary>
    /// Represents a qubit register used by an <see cref="Operation"/>.
    /// </summary>
    public class QubitRegister : Register
    {
        /// <summary>
        /// Creates a new <see cref="QubitRegister"/> with the given qubit id.
        /// </summary>
        /// <param name="qId">
        /// Id of qubit register.
        /// </param>
        public QubitRegister(int qId) => this.QId = qId;

        /// <inheritdoc/>
        public override RegisterType Type => RegisterType.Qubit;
    }

    /// <summary>
    /// Represents a classical register used by an <see cref="Operation"/>.
    /// </summary>
    public class ClassicalRegister : Register
    {
        /// <summary>
        /// Creates a new <see cref="ClassicalRegister"/> with the given qubit id and classical bit id.
        /// </summary>
        /// <param name="qId">
        /// Id of qubit register.
        /// </param>
        /// <param name="cId">
        /// Id of classical register associated with the given qubit id.
        /// </param>
        public ClassicalRegister(int qId, int cId)
        {
            this.QId = qId;
            this.CId = cId;
        }

        /// <inheritdoc/>
        public override RegisterType Type => RegisterType.Classical;
    }
}
