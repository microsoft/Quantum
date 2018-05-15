using System;
using System.Collections.Generic;
using System.Text;

namespace OpenQasmReader
{
    public class TraditionalRegister : IQasmElement
    { 
        public string Name { get; set; }
        public int Count { get; set; }
        public TraditionalRegister(string name, int count)
        {
            Name = name;
            Count = count;
        }

        public string GetQSharp()
        {
            return $"mutable {Name} = new Result[{Count}];";
        }
    }
}
