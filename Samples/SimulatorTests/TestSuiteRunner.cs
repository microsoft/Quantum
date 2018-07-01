using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.XUnit;
using Xunit;
using Xunit.Abstractions;
using System.Diagnostics;
using System;

namespace Quantum.SimulatorTests
{
    public class TestSuiteRunner
    {
        private readonly ITestOutputHelper output;

        public TestSuiteRunner(ITestOutputHelper output)
        {
            this.output = output;
        }

        /// <summary>
        /// This driver will run all Q# tests (operations named "...Test") 
        /// that belong to namespace Quantum.SimulatorTests.
        /// </summary>
        [OperationDriver]
        public void QuantumSimulatorTarget(TestOperation op)
        {
            using (var sim = new QuantumSimulator())
            {
                // OnLog defines action(s) performed when Q# test calls function Message
                sim.OnLog += (msg) => { output.WriteLine(msg); };
                sim.OnLog += (msg) => { Debug.WriteLine(msg); };
                op.TestOperationRunner(sim);
            }
        }

        // one can find tests with custom suffix
        [OperationDriver(Suffix = "TestOutOfRange")]
        public void QuantumSimulatorTargetOutOfRange(TestOperation opData)
        {
            using (var sim = new QuantumSimulator())
            {
                // OnLog defines action(s) performed when Q# test calls function Message
                sim.OnLog += (msg) => { output.WriteLine(msg); };
                sim.OnLog += (msg) => { Debug.WriteLine(msg); };

                // executes operation and expects and exception from Q#
                Assert.ThrowsAny<ArgumentOutOfRangeException>(() => opData.TestOperationRunner(sim));
            }
        }


        // one can find tests with custom suffix
        [OperationDriver(Suffix = "TestShouldFail")]
        public void QuantumSimulatorTargetShouldFail(TestOperation opData)
        {
            using (var sim = new QuantumSimulator())
            {
                // OnLog defines action(s) performed when Q# test calls function Message
                sim.OnLog += (msg) => { output.WriteLine(msg); };
                sim.OnLog += (msg) => { Debug.WriteLine(msg); };

                // executes operation and expects and exception from Q#
                Assert.ThrowsAny<ExecutionFailException>(() => opData.TestOperationRunner(sim));
            }
        }
    }
}
