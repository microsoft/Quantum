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
            Console.Write(Parser.ParseQasmFile("Quantum.OpenQasmImported", @"C:\Quantum\openqasm\examples\generic\adder.qasm"));
            Console.ReadLine();
        }
    }
}