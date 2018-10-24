using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Quantum.ReVerC
{
    class Driver
    {
        static void Main(string[] args)
        {
            using (var sim = new QuantumSimulator())
            {
                QArray<Result> a = new QArray<Result> { Result.One, Result.Zero };
                QArray<Result> b = new QArray<Result> { Result.One, Result.Zero };

                var result = add.Run(sim, a, b).Result;

                System.Console.WriteLine($"1 + 1 = {result}");
            }
            System.Console.WriteLine("Press any key to to continue...");
            System.Console.ReadKey();
        }
    }
}