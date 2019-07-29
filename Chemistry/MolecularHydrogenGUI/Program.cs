// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Collections.Generic;
using Newtonsoft.Json;
using Microsoft.Quantum.Simulation.Simulators;
using System.Runtime.InteropServices;
using System.Linq;
using Microsoft.Quantum.Chemistry.Fermion;
using Microsoft.Quantum.Chemistry.OrbitalIntegrals;
using Microsoft.Quantum.Chemistry.QSharpFormat;


namespace Microsoft.Quantum.Chemistry.Samples.Hydrogen
{
    internal static class HydrogenSimulation
    {
        // We now plot estimates of the ground state energy for
        // molecular Hydrogen as a function of bond distance.

        // Here, we load a list of Hydrogen Hamiltonians from the included file
        // "dis_H2.dat".
        internal static IEnumerable<LiQuiD.ProblemDescription> problemData =
            LiQuiD.Deserialize("dis_H2.dat");

        // For each Hamiltonian, 
        internal static (Double, Double) GetSimulationResult(int idxBond)
        {
            // Choose the desired problem indexed by `idx`.
            var problem = problemData.ElementAt(idxBond);

            // Create fermion representation of Hamiltonian.
            var fermionHamiltonian = problem.OrbitalIntegralHamiltonian
                    .ToFermionHamiltonian(IndexConvention.UpDown);

            // Create Jordan–Wigner encoding of Hamiltonian.
            var jordanWignerEncoding = fermionHamiltonian.ToPauliHamiltonian(Paulis.QubitEncoding.JordanWigner);


            // Bond length conversion from Bohr radius to Angstrom
            double bondLength = Double.Parse(problem.MiscellaneousInformation.Split(new char[] { ',' }).Last()) * 0.5291772;

            // Create input wavefunction.
            var wavefunction = fermionHamiltonian.CreateHartreeFockState(nElectrons: 2);

            // Choose bits of precision in quantum phase estimation
            Int64 bitsOfPrecision = 7;

            // Choose the Trotter step size.
            Double trotterStepSize = 1.0;

            // Choose the Trotter integrator order
            Int64 trotterOrder = 1;

            // Invoke quantum simulator and run `GetEnergyByTrotterization` in the first
            // molecular Hydrogen sample.
            using (var qSim = new QuantumSimulator())
            {
                // Package hamiltonian and wavefunction data into a format
                // consumed by Q#.
                var qSharpData = QSharpFormat.Convert.ToQSharpFormat(
                    jordanWignerEncoding.ToQSharpFormat(),
                    wavefunction.ToQSharpFormat());

                System.Console.WriteLine($"Estimating at bond length {idxBond}:");
                // Loop if excited state energy is obtained.
                var energyEst = 0.0;
                do
                {
                    var (phaseEst, energyEstTmp) = GetEnergyByTrotterization.Run(qSim, qSharpData, bitsOfPrecision, trotterStepSize, trotterOrder).Result;
                    energyEst = energyEstTmp;
                } while (energyEst > -0.8);

                return (bondLength, energyEst);
            }
        }

        // Theorertical energy data for comparison.
        internal static readonly double[] theoryEnergyData = {
            0.14421, -0.323939, -0.612975, -0.80051, -0.92526,
            -1.00901, -1.06539, -1.10233, -1.12559, -1.13894,
            -1.14496, -1.1456, -1.14268, -1.13663, -1.12856,
            -1.1193, -1.10892, -1.09802, -1.08684, -1.07537,
            -1.06424, -1.05344, -1.043, -1.03293, -1.02358,
            -1.01482, -1.00665, -0.999025, -0.992226, -0.985805,
            -0.980147, -0.975156, -0.970807, -0.966831, -0.963298,
            -0.960356, -0.957615, -0.95529, -0.953451, -0.951604,
            -0.950183, -0.949016, -0.947872, -0.946982, -0.946219,
            -0.945464, -0.944887, -0.944566, -0.94415, -0.943861,
            -0.943664, -0.943238, -0.943172, -0.942973
        };

        // Theorertical bond distance data for comparison.
        internal static readonly double[] theoryDistanceData = {
            0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65,
            0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0, 1.05, 1.1, 1.15,
            1.2, 1.25, 1.3, 1.35, 1.4, 1.45, 1.5, 1.55, 1.6, 1.65,
            1.7, 1.75, 1.8, 1.85, 1.9, 1.95, 2.0, 2.05, 2.1, 2.15,
            2.2, 2.25, 2.3, 2.35, 2.4, 2.45, 2.5, 2.55, 2.6, 2.65,
            2.7, 2.75, 2.8, 2.85
        };
    }

    #region Real-time plotting functionality
    class ServerThread
    {
        
        private static byte[] SerializeResponse(string respType, object response) =>
            System.Text.Encoding.UTF8.GetBytes(
                JsonConvert.SerializeObject(
                    new Dictionary<string, object>
                    {
                        { "type", respType },
                        { "data", response }
                    }
                ) + "\f"
            );

        private static void SendPlotPoints(NetworkStream stream)
        {
            // Plot theory data points first
            foreach (var idxBond in Enumerable.Range(0, HydrogenSimulation.theoryEnergyData.Length))
            {
                var response = SerializeResponse(
                        "plotPoint",
                        new Dictionary<string, object>
                        {
                            { "source", "theory" },
                            { "bondLength", HydrogenSimulation.theoryDistanceData[idxBond] },
                            { "theoreticalEnergy", HydrogenSimulation.theoryEnergyData[idxBond] },
                        }
                    );
                stream.Write(response, 0, response.Length);
            }

            // Now plot simulation results                
            foreach (var idxBond in Enumerable.Range(0, 25))
            {
                var (bondLength, energyEst) = HydrogenSimulation.GetSimulationResult(idxBond);


                var response = SerializeResponse(
                    "plotPoint",
                    new Dictionary<string, object>
                    {
                        { "source", "simulation" },
                        { "bondLength", bondLength },
                        { "estEnergy", energyEst }
                    }
                );
                stream.Write(response, 0, response.Length);
            }
        }

        public static void Start()
        {
            TcpListener server = null;

            try
            {
                var port = 8010;
                var localAddress = IPAddress.Parse("127.0.0.1");

                server = new TcpListener(localAddress, port);
                server.Start();

                while (true)
                {
                    var client = server.AcceptTcpClient();
                    Console.WriteLine("@@ Connected to client. @@");

                    // Allocate a buffer.
                    var buffer = new Byte[256];

                    var stream = client.GetStream();

                    var nBytesRead = -1;
                    while ((nBytesRead = stream.Read(buffer, 0, buffer.Length)) != 0)
                    {
                        var rawMessage = System.Text.Encoding.UTF8.GetString(buffer, 0, nBytesRead);
                        Console.WriteLine($"@@ Received from client: {rawMessage} @@");

                        var message = JsonConvert.DeserializeObject<Dictionary<string, object>>(rawMessage);
                        message.TryGetValue("type", out var messageType);
                        message.TryGetValue("data", out var messageData);
                        if ((string)messageType == "event" && (string)messageData == "readyToPlot")
                        {
                            Console.WriteLine("@@ Got request for plotting data, running simulator. @@");
                            SendPlotPoints(stream);
                        }
                    }

                }

            }

            finally
            {
                server.Stop();
            }

        }

    }

    class Program
    {
        static string FindOnPath(string fileName)
        {
            foreach (var candidateRoot in (
                System.Environment.GetEnvironmentVariable("PATH").Split(
                    Path.PathSeparator
                ))
            )
            {
                var path = Path.Combine(candidateRoot.Trim(), fileName);
                if (File.Exists(path))
                {
                    return path;
                }
            }

            throw new FileNotFoundException($"Did not find {fileName} on $Env:PATH.");
        }
        
        static void Main(string[] args)
        {
            Console.WriteLine("Starting Simulation Server...");
            var serverThread = new Thread(ServerThread.Start);
            serverThread.Start();

            Console.WriteLine("Starting GUI...");

            var process = new System.Diagnostics.Process
            {
                StartInfo = new System.Diagnostics.ProcessStartInfo
                {
                    FileName = FindOnPath(
                        RuntimeInformation.IsOSPlatform(OSPlatform.Windows)
                        ? "npm.cmd" : "npm"
                    ),
                    UseShellExecute = false,
                    Arguments = "start",
                    CreateNoWindow = true
                }
            };
            process.Start();
            process.WaitForExit();

            // Check the npm process' exit code to make sure that npm
            // start actually ran correctly.
            while (!process.HasExited) {
                System.Threading.Thread.Sleep(500);
            }
            if (process.ExitCode != 0) {
                System.Console.WriteLine($"GUI returned exit code {process.ExitCode}; did you run npm install?");
            }

            // If we got this far, go on and call Environment's exit method,
            // killing the server thread.
            System.Environment.Exit(process.ExitCode);
        }
    }
    #endregion
}
