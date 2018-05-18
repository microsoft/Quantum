// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.OpenQasmReader
{
    /// <summary>
    /// Represents a controlled not Gate
    /// </summary>
    public class ControledNot : IQasmElement
    {
        public ControledNot(string control, string qubit)
        {
            Control = control;
            Qubit = qubit;
        }

        public string Control { get; set; }
        public string Qubit { get; set; }

        public string GetQSharp()
        {
            return $"CNOT ({Control},{Qubit});";
        }
    }
}