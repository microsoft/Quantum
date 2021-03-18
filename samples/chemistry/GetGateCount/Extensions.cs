using System;
using System.Diagnostics;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Chemistry.Samples
{
    public static class Extensions
    {
        public static void WriteResultsToFolder(
            this QCTraceSimulator sim,
            string outputFolder,
            string baseName
        )
        {
            var gateStats = sim.ToCSV();
            foreach (var x in gateStats)
            {
                System.IO.File.WriteAllLines(
                    System.IO.Path.Join(
                        outputFolder,
                        $"{baseName}.{x.Key}.csv"
                    ), new string[] { x.Value }
                );
            }
        }

        public async static Task<T> Measure<T>(
            this Stopwatch stopwatch,
            Func<Task<T>> action
        )
        {
            stopwatch.Reset();
            stopwatch.Start();
            var result = await action();
            stopwatch.Stop();
            return result;
        }
    }
}