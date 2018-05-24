using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Samples.OpenQasmReader;
using System;

namespace Quantum.OpenQasmImported
{
    class Driver
    {
        static void Main(string[] args)
        {
            Parser.Main(new string[] {
                "Quantum.OpenQasmImported", @"C:\Quantum\openqasm\examples\generic\adder.qasm" });
            Console.ReadLine();
        }
    }
}