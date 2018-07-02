// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.XUnit;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Text;
using Xunit;

namespace Microsoft.Quantum.Tests
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

        // note that one can provide custom namespace where to search for tests
        [OperationDriver(TestNamespace = "Microsoft.Quantum.Tests")]
        public void QuantumSimulatorTarget(TestOperation opData)
        {
            // It is convenient to store seed for test that can fail with small probability
            uint? seed = RetrieveGeneratedSeed(opData);

            try
            {
                using (var sim = new QuantumSimulator(randomNumberGeneratorSeed: seed))
                {
                    // Frequently tests include measurement and randomness. 
                    // To reproduce the failed test it is useful to record seed that has been used 
                    // for the random number generator inside the simulator.
                    LogSimulatorSeed(opData, sim);

                    // This ensures that when the test is run in Debug mode, all message logged in 
                    // Q# by calling Microsoft.Quantum.Primitives.Message show-up 
                    // in Debug output 
                    sim.OnLog += (string message) => { Debug.WriteLine(message); };

                    // this ensures that all message logged in Q# by calling
                    // Microsoft.Quantum.Primitives.Message show-up 
                    // in test output 
                    sim.OnLog += (string message) => { output.WriteLine(message); };

                    // executes operation
                    opData.TestOperationRunner(sim);
                }
            }
            catch( System.BadImageFormatException e )
            {
                throw new System.BadImageFormatException($"Could not load Quantum Simulator. If you are running tests using Visual Studio 2017, " +
                    $"this problem can be fixed by using menu Test > Test Settings > Default Processor Architecture " +
                    $"and switching to X64 instead of X86. Alternatively, press Ctrl+Q and type `Default Processor Architecture`. If you are running from command line using " +
                    $"vstest.console.exe use command line option /Platform:x64.", e );
            }
        }

        [OperationDriver(TestNamespace = "Microsoft.Quantum.Canon")]
        public void QuantumSimulatorCanonTarget(TestOperation opData)
        {
            // It is convenient to store seed for test that can fail with small probability
            uint? seed = RetrieveGeneratedSeed(opData);

            using (var sim = new QuantumSimulator(randomNumberGeneratorSeed: seed))
            {
                // Frequently tests include measurement and randomness. 
                // To reproduce the failed test it is useful to record seed that has been used 
                // for the random number generator inside the simulator.
                LogSimulatorSeed(opData, sim);

                // This ensures that when the test is run in Debug mode, all message logged in 
                // Q# by calling Microsoft.Quantum.Primitives.Message show-up 
                // in Debug output 
                sim.OnLog += (string message) => { Debug.WriteLine(message); };

                // this ensures that all message logged in Q# by calling
                // Microsoft.Quantum.Primitives.Message show-up 
                // in test output 
                sim.OnLog += (string message) => { output.WriteLine(message); };

                // executes operation
                opData.TestOperationRunner(sim);
            }
        }

        [OperationDriver(TestNamespace = "Microsoft.Quantum.Canon", AssemblyName ="Microsoft.Quantum.Canon")]
        public void QuantumSimulatorOldCanonTarget(TestOperation opData)
        {
            // It is convenient to store seed for test that can fail with small probability
            uint? seed = RetrieveGeneratedSeed(opData);

            using (var sim = new QuantumSimulator(randomNumberGeneratorSeed: seed))
            {
#if DEBUG
                // Frequently tests include measurement and randomness. 
                // To reproduce the failed test it is useful to record seed that has been used 
                // for the random number generator inside the simulator.
                LogSimulatorSeed(opData, sim);

                // This ensures that when the test is run in Debug mode, all message logged in 
                // Q# by calling Microsoft.Quantum.Primitives.Message show-up 
                // in Debug output 
                sim.OnLog += (string message) => { Debug.WriteLine(message); };

                // this ensures that all message logged in Q# by calling
                // Microsoft.Quantum.Primitives.Message show-up 
                // in test output 
                sim.OnLog += (string message) => { output.WriteLine(message); };

                // executes operation
                opData.TestOperationRunner(sim);
#else
                throw new System.Exception("Tests should be removed from Microsoft.Quantum.Canon.dll.");
#endif
            }
        }

        // when Skip attribute is specified the test will be skipped and marked with yellow icon
        [OperationDriver(Suffix = "TestExFail", Skip = "This test is expected to fail.")]
        public void QuantumSimulatorTargetExFail(TestOperation opData)
        {
            // It is convenient to store seed for test that can fail with small probability
            uint? seed = RetrieveGeneratedSeed(opData);

            using (var sim = new QuantumSimulator(randomNumberGeneratorSeed: seed))
            {
                // Frequently tests include measurement and randomness. 
                // To reproduce the failed test it is useful to record seed that has been used 
                // for the random number generator inside the simulator.
                LogSimulatorSeed(opData, sim);

                // This ensures that when the test is run in Debug mode, all message logged in 
                // Q# by calling Microsoft.Quantum.Primitives.Message show-up 
                // in Debug output 
                sim.OnLog += (string message) => { Debug.WriteLine(message); };

                // this ensures that all message logged in Q# by calling
                // Microsoft.Quantum.Primitives.Message show-up 
                // in test output 
                sim.OnLog += (string message) => { output.WriteLine(message); };

                // executes operation
                opData.TestOperationRunner(sim);
            }
        }

        // one can find tests with custom suffix
        [OperationDriver(Suffix = "TestShouldFail")]
        public void QuantumSimulatorTargetShouldFail(TestOperation opData)
        {
            // It is convenient to store seed for test that can fail with small probability
            uint? seed = RetrieveGeneratedSeed(opData);

            using (var sim = new QuantumSimulator(randomNumberGeneratorSeed: seed))
            {
                // Frequently tests include measurement and randomness. 
                // To reproduce the failed test it is useful to record seed that has been used 
                // for the random number generator inside the simulator.
                LogSimulatorSeed(opData, sim);

                // This ensures that when the test is run in Debug mode, all message logged in 
                // Q# by calling Microsoft.Quantum.Primitives.Message show-up 
                // in Debug output 
                sim.OnLog += (string message) => { Debug.WriteLine(message); };

                // this ensures that all message logged in Q# by calling
                // Microsoft.Quantum.Primitives.Message show-up 
                // in test output 
                sim.OnLog += (string message) => { output.WriteLine(message); };

                // executes operation and expects and exception from Q#
                Assert.ThrowsAny<ExecutionFailException>(() => opData.TestOperationRunner(sim));
            }
        }

        /// <summary>
        /// Logs the seed used for the test run
        /// </summary>
        private void LogSimulatorSeed(TestOperation opData, QuantumSimulator sim)
        {
            // Frequently tests include measurement and randomness. 
            // To reproduce the failed test it is useful to record seed that has been used 
            // for the random number generator inside the simulator.
            string msg = $"The seed, operation pair is (\"{ opData.fullClassName}\",{ sim.Seed})";
            output.WriteLine(msg);
            Debug.WriteLine(msg);
        }

        /// <summary>
        /// Returns a seed to use for the test run based on the class
        /// </summary>
        private uint? RetrieveGeneratedSeed(TestOperation opData)
        {
            byte[] bytes = Encoding.Unicode.GetBytes(opData.fullClassName);
            byte[] hash = hashMethod.ComputeHash(bytes);
            uint seed = BitConverter.ToUInt32(hash, 0);
            
            string msg = $"Using generated seed: (\"{ opData.fullClassName}\",{ seed })";
            output.WriteLine(msg);
            Debug.WriteLine(msg);

            return seed;
        }

        private static readonly SHA256Managed hashMethod = new SHA256Managed();
    }
}
