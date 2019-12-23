// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;


namespace Qrng
{
    class Driver
    {
        static void Main(string[] args)
        {
            using (var sim = new QuantumSimulator())
            {
                // First we initialize all the variables:
                var bitString = "0"; // To save the bit string
                var a = "0"; // Auxiliary string variable
                int max = 50; // The maximum of the range 
                bool b = false; // Auxiliary bool
                int size = Convert.ToInt32(Math.Floor(Math.Log(max, 2.0) + 1));
                // To calculate the amount of needed bits
                int output = max + 1; // Int to store the output
                while (output > max)  // Loop to generate the number
                {
                    bitString = "0"; // Restart the bit string if fails 
                    for(int counter = 0; counter < size ; counter++){
                        b = (QuantumRandomNumberGenerator.Run(sim).Result == Result.One); 
                        // Call the Q# operation and transform the result to bool
                        a = b ? "0" : "1"; // Transform the bool to string
                        bitString = bitString + a; // Concatenate bits
                    }
                    output = Convert.ToInt32(bitString, 2);
                    // Convert the bit string to an integer
                }
                // Print the result
                Console.WriteLine($"The random number generated is {output}.");
            }
         }
      }
    }
