using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using OpenQasmReader;
using System;

namespace Quantum.OpenQasmImported
{
    class Driver
    {
        static void Main(string[] args)
        {
            Console.Write(Parser.Parse(@"C:\Quantum\openqasm\examples\generic\adder.qasm").GetQSharp());
            Console.ReadLine();
        }
    }
}