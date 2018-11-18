using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;

namespace Microsoft.Quantum.Guess
{
	class Driver
	{
		static void Main(string[] args)
		{
			using (var sim = new QuantumSimulator())
			{
				var res = Guess.Run(sim).Result;
				Console.WriteLine(res);
			}

			Console.WriteLine("Press any key to continue ...");
			Console.ReadKey();
		}
	}
}
