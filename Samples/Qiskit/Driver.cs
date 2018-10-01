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
        /// Sample to show that one can substitue the operation factory 
        /// to run on different types of machines.
        /// </summary>
        /// <param name="args"></param>
        static void Main(string[] args)
        {
            //You need to replace this with your own key from the quantum experience
            var apiKey = "e8fdf62db87cc17a516201ecea77e2f1e42394b0b6f12d9c9367a44bf7eea95340747737e3b5bc6867d48dd82ea3fa8ec375db9b74fede36bbb2afa210ca3613";
            if (apiKey.Contains("."))
            {
                Console.Error.WriteLine("Did you put an api key in Driver.cs ? Without that, it will not work.");
            }
            else
            {
                var factory = new IbmQ16Melbourne(apiKey); //Using different Factory
                Console.WriteLine("Hadamard on IBM Q 16 Melbourne");
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