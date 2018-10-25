using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Quantum.ReVerC;

namespace Microsoft.Quantum.Samples.ReVerC
{
    class Driver
    {
        static void Main(string[] args)
        {
            using (var sim = new QuantumSimulator())
            {
                // Little-endian two-bit integers to be added. As integers, a=1=b
                var a = new QArray<Result> { Result.One, Result.Zero };
                var b = new QArray<Result> { Result.One, Result.Zero };

                var result = Add.Run(sim, a, b).Result;

                System.Console.WriteLine($"1 + 1 = {result}");
            }
            System.Console.WriteLine("Press any key to to continue...");
            System.Console.ReadKey();
        }
    }
}