using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using System.Diagnostics;

namespace Quantum.QCLA
{
    /// <summary>
    /// This is a Console program that runs the resource estimator on different adders
    /// if args is empty or args[0] == 0 it runs QCLA
    /// if                  args[0] == 1 it runs MAP
    /// if                  args[0] == 2 it runs RCA 
    /// </summary>
    class Program
    {
        static void Main(string[] args) {
            int adder = 0;
            if (args.Length >= 1) {
                adder = Int32.Parse(args[0]);
            }

            String[] header = {"Qubits", "CNOT", "T", "Depth", "Width"};
            WriteRow(header);
            int max = 1024;
            if (adder == 1) 
                max = 60;
            for (int i = 8; i <= max; i*=2) {
                Console.Write("" + i);
                Console.Write("\t");
                ResourcesEstimator estimator = new ResourcesEstimator();
                T_NBit.Run(estimator, i, adder).Wait();
                var data = estimator.Data;
                
                String[] row = {$"{data.Rows.Find("CNOT")["Sum"]}",  $"{data.Rows.Find("T")["Sum"]}",
                $"{data.Rows.Find("Depth")["Sum"]}", $"{data.Rows.Find("Width")["Sum"]}"};
                WriteRow(row);
            }
        }

        static void WriteRow(String[] args) {
            for (int i = 0; i < args.Length; i++) {
                Console.Write(args[i]);
                Console.Write("\t");
            }
            Console.WriteLine();
        }
    }
}
