using System;
using System.Diagnostics;
using Microsoft.Quantum.Simulation.Simulators;
using Xunit.Abstractions;


namespace Microsoft.Quantum.TutorialTests
{
    public partial class CircuitSimulator
    {
        private readonly ITestOutputHelper output;

        public CircuitSimulator(ITestOutputHelper output)
        { this.output = output; }

        internal void RunTest(Action<QuantumSimulator> test)
        {
            using (var sim = new QuantumSimulator())
            {
                sim.OnLog += (msg) => { output.WriteLine(msg); };
                sim.OnLog += (msg) => { Debug.WriteLine(msg); };
                test(sim);
            }
        }
    }
}
