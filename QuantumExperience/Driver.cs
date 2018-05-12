// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Samples.Quantum.Qasm;
using System;

namespace Microsoft.Quantum.Samples.Qasm
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
            var factory = new ConsoleDriver(); //Using different Factory
            Console.WriteLine("Hadamard to Qasm");
            Hadamard.Run(factory);
            Console.WriteLine("Press Enter to continue...");
            Console.ReadLine();

            Console.WriteLine("Measurement bell curve to Qasm");
            MeasurementBellBasis.Run(factory);
            Console.WriteLine("Press Enter to continue...");
            Console.ReadLine();
        }
    }
}