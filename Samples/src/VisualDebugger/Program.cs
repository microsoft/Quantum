using Microsoft.Quantum.Simulation.Simulators;

namespace vis_sim
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            var debugger = new VisualDebugger(new QuantumSimulator());
            debugger.Run(HelloQ.Run).Wait();
        }
    }
}
