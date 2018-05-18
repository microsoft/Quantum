// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace Microsoft.Quantum.Samples.OpenQasmReader
{
    /// <summary>
    /// Represents a method in QSharp
    /// </summary>
    public class Method : IQasmElement
    {
        private IList<TraditionalRegister> cregs = new List<TraditionalRegister>();
        private IList<QuantumRegister> qregs = new List<QuantumRegister>();
        private IList<IQasmElement> elements = new List<IQasmElement>();
        private string[] Parameters { get; set; } = new string[0];

        private string Name { get; set; }

        public Method(string operationName)
        {
            operationName = operationName.Replace(' ', '_');
            Name = operationName.First().ToString().ToUpper() + operationName.Substring(1);
        }

        public Method(string operationName, string[] parameters) : this(operationName)
        {
            Parameters = parameters;
        }

        public string GetQSharp()
        {
            var buffer = new StringBuilder();
            buffer.AppendLine($"\toperation {Name}():({string.Join(",", Enumerable.Repeat("Result[]", cregs.Count))})");
            buffer.AppendLine("\t{");
            buffer.AppendLine("\t\tbody");
            buffer.AppendLine("\t\t{");
            foreach (var creg in cregs)
            {
                buffer.Append($"\t\t\t");
                buffer.AppendLine(creg.GetQSharp());
            }
            foreach (var qreg in qregs)
            {
                buffer.Append($"\t\t\t");
                buffer.AppendLine(qreg.GetQSharp());
            }
            if (qregs.Count != 0) { buffer.Append("\t\t\t{"); }

            foreach (var element in elements)
            {
                buffer.Append("\t\t\t");
                buffer.AppendLine(element.GetQSharp());
            }
            if (qregs.Count != 0) { buffer.AppendLine("\t\t\t}"); }
            if (cregs.Count != 0) { buffer.AppendLine($"\t\t\tReturn ({string.Join(",",cregs.Select(c=> c.Name))});"); }
            buffer.AppendLine("\t\t}");
            buffer.AppendLine("\t}");
            return buffer.ToString();
        }

        public void Append(IQasmElement element)
        {
            elements.Add(element);
        }

        public void AddTraditionalRegister(TraditionalRegister traditionalRegister)
        {
            cregs.Add(traditionalRegister);
        }

        public void AddQuantumReqister(QuantumRegister quantumRegister)
        {
            qregs.Add(quantumRegister);
        }
    }
}