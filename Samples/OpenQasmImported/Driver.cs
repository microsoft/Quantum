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
            foreach (var method in Parser.Parse(@"C:\Quantum\openqasm\examples\generic\adder.qasm"))
            {
                Console.WriteLine(method.GetQSharp());
            }
            Console.ReadLine();
        }
    }
}