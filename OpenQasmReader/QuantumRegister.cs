using System;
using System.Collections.Generic;
using System.Text;

namespace OpenQasmReader
{
    public class QuantumRegister : IQasmElement
    {
        public string Name { get; set; }
        public int Count { get; set; }
        public QuantumRegister(string name, int count)
        {
            Name = name;
            Count = count;
        }

        public string GetQSharp()
        {
            return $"using ({Name} = Qubit[{Count}])";
        }
    }
}
