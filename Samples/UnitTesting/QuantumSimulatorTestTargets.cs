// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.XUnit;
using System;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Text;

///////////////////////////////////////////////////////////////////////////////////////////////////
// This file makes sure that all Q# operations ending with Test
// in Microsoft.Quantum.Samples.UnitTesting namespace are 
// executed as Tests on QuantumSimulator. 
///////////////////////////////////////////////////////////////////////////////////////////////////

namespace Microsoft.Quantum.Samples.UnitTesting
{
    public class SimulatorTestTargets
    {
        /// <summary>
        /// Interface provided by Xunit framework for logging during test execution.
        /// When the test is selected in Visual Studio Test Explore window 
        /// there is an Output text link available for each test. 
        /// </summary>
        private readonly Xunit.Abstractions.ITestOutputHelper output;

        public SimulatorTestTargets(Xunit.Abstractions.ITestOutputHelper output)
        {
            this.output = output;
        }

        /// <summary>All Q# procedures ending with Test in the same namespace as this class are 
        /// discovered and passed to this function as an argument. 
        /// </summary>
        [OperationDriver]
        public void QuantumSimulatorTarget(TestOperation operationDescription)
        {
            try
            {
                // Generate seed based on name of testclass, so testruns are more deterministic
                // but we don't always use the same seed throughout the solution.
                byte[] bytes = Encoding.Unicode.GetBytes(operationDescription.fullClassName);
                byte[] hash = hashMethod.ComputeHash(bytes);
                uint seed = BitConverter.ToUInt32(hash, 0);

                using (var sim = new QuantumSimulator(randomNumberGeneratorSeed:seed))
                {
                    // Frequently tests include measurement and randomness. 
                    // To reproduce the failed test it is useful to record seed that has been used 
                    // for the random number generator inside the simulator.
                    output.WriteLine($"The seed used for this test is {sim.Seed}");
                    Debug.WriteLine($"The seed used for this test is {sim.Seed}");

                    // This ensures that when the test is run in Debug mode, all message logged in 
                    // Q# by calling Microsoft.Quantum.Primitives.Message show-up 
                    // in Debug output 
                    sim.OnLog += (string message) => { Debug.WriteLine(message); };

                    // this ensures that all message logged in Q# by calling
                    // Microsoft.Quantum.Primitives.Message show-up 
                    // in test output 
                    sim.OnLog += (string message) => { output.WriteLine(message); };

                    // Executes operation described by operationDescription on a QuantumSimulator
                    operationDescription.TestOperationRunner(sim);
                }
            }
            catch (System.BadImageFormatException e)
            {
                throw new System.BadImageFormatException($"Could not load Quantum Simulator. If you are running tests using Visual Studio 2017, " +
                    $"this problem can be fixed by using menu Test > Test Settings > Default Processor Architecture " +
                    $"and switching to X64 instead of X86. Alternatively, press Ctrl+Q and type `Default Processor Architecture`. If you are running from command line using " +
                    $"vstest.console.exe use command line option /Platform:x64.", e);
            }
        }

        private static readonly SHA256Managed hashMethod = new SHA256Managed();
    }
}
