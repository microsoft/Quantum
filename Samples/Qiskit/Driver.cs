// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Samples.Measurement;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;

namespace Microsoft.Quantum.Samples.Qiskit
{
    class Driver
    {
        /// <summary>
        /// Sample to show that one can substitute the operation factory 
        /// to run on different types of machines.
        /// </summary>
        /// <param name="args"></param>
        static void Main(string[] args)
        {
            //You need to replace this with your own key from the quantum experience
            var apiKey = "4616efdc29c9d4d751b3cd23a2e7d677ef8a..........623614734c2e11e25f9";
            if (apiKey.Contains("."))
            {
                Console.Error.WriteLine("Did you put an api key in Driver.cs ? Without that, it will not work.");
            }
            else
            {
                var factory = new IbmQx4(apiKey); //Using different Factory
                Console.WriteLine("Hadamard on IBMQx4");
                for (int i = 0; i < 1; i++)
                {
                    var result = MeasurementOneQubit.Run(factory).Result;
                    Console.WriteLine($"Result of Hadamard is {result}");
                }
            }

            Console.WriteLine("Press Enter to continue...");
            Console.ReadLine();
        }
    }
}
