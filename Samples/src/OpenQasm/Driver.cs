// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;
using Microsoft.Quantum.Samples.Measurement;

namespace Microsoft.Quantum.Samples.OpenQasm
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
            var factory = new ConsoleDriver(); //Using different Factory
            Console.WriteLine("Hadamard to Qasm");
            MeasurementOneQubit.Run(factory).Wait();
            Console.WriteLine("Press Enter to continue...");
            Console.ReadLine();

            Console.WriteLine("Measurement bell curve to Qasm");
            MeasurementBellBasis.Run(factory).Wait();
            Console.WriteLine("Press Enter to continue...");
            Console.ReadLine();
        }
    }
}
