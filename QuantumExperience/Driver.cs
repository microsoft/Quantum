using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Quantum.Quasm;
using Quasm.Qiskit;
using System;

namespace Quasm
{
    class Driver
    {
        /// <summary>
        /// Sample to show that one can substitue the operation factory 
        /// to run on different types of machines.
        /// </summary>
        /// <param name="args"></param>
        static void Main(string[] args)
        {
            //You need to replace this with your own key from the quantum experience
            var apiKey = "4616efdc29c9d4d751b3cd23a2e7d677ef8a6ff22b693afe0352e4f42b63e3a1135dc368484400b53cf7f4c8b96dcabf7cfc08442f2a1623614734c2e11e25f9";
            var factory = new IbmQx4(apiKey); //Using different Factory
            Console.WriteLine("Hadamard on IBMQx4");
            for (int i = 0; i < 1; i++)
            {
                var result = Hadamard.Run(factory).Result;
                Console.WriteLine($"Result of Hadamard is {result}");
            }

            Console.WriteLine("Press Enter to continue...");
            Console.ReadLine();
        }
    }
}