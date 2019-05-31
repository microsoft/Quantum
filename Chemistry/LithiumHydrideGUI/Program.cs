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
using Microsoft.Quantum.Chemistry.Fermion;
using Microsoft.Quantum.Chemistry.OrbitalIntegrals;
using Microsoft.Quantum.Chemistry.QSharpFormat;
using System.Runtime.InteropServices;
using System.Linq;
using Mono.Options;


namespace Microsoft.Quantum.Chemistry.Samples.LiH
{
    using Microsoft.Quantum.Chemistry.Samples.Hydrogen;
    internal static class LiHSimulation
    {
        // We now plot estimates of the ground state energy for
        // molecular Hydrogen as a function of bond distance.

        // Here, we load a list of Lithium Hydride Hamiltonians from the included files.
        internal static string[] bondLengths = new string[]
        {
        "0.800","1.000","1.200","1.400","1.500","1.550","1.580","1.600","1.624",
        "1.640","1.680","1.700","1.800","2.000","2.200","2.500","2.700","3.000",
        "3.200","3.500","4.000","5.000"
        };

        internal static string[] filenames = bondLengths.Select(o => $@"..\IntegralData\YAML\LiHData\integrals_lih_sto-3g_{o}.nw.out.yaml").ToArray();

        internal static Broombridge.ProblemDescription[] problemData =
            filenames.Select(o => 
                Broombridge.Deserializers.DeserializeBroombridge(o)
                .ProblemDescriptions.Single()).ToArray();

        // Order of Trotter-Suzuki integrator.
        public static Int64 IntegratorOrder = 1;

        // Choose bits of precision in quantum phase estimation
        public static Int64 bitsOfPrecision = 8;

        // Choose the Trotter step size.
        public static Double trotterStepSize = 0.5;

        // Perform quantum simulation of Hamiltonian at desired bond length and 
        // return estimate of energy.
        internal static (Double, Double) GetSimulationResult(int idxBond, string inputState = "Greedy")
        {
            // Choose the desired Hamiltonian indexed by `idx`.
            var problem = problemData.ElementAt(idxBond);

            // Bond length conversion from Bohr radius to Angstrom
            var bondLength = Double.Parse(bondLengths[idxBond]);
            
            // Create fermion representation of Hamiltonian
            var fermionHamiltonian = problem
                .OrbitalIntegralHamiltonian
                .ToFermionHamiltonian(IndexConvention.UpDown);

            // Crete Pauli reprsentation of Hamiltonian using
            // the Jordan–Wigner encoding.
            var pauliHamiltonian = fermionHamiltonian
                .ToPauliHamiltonian(Paulis.QubitEncoding.JordanWigner);

            // Create input wavefunction.
            var wavefunction = inputState == "Greedy" ?
                fermionHamiltonian.CreateHartreeFockState(problem.NElectrons) :
                problem.Wavefunctions[inputState].ToIndexing(IndexConvention.UpDown);


            // Package Hamiltonian and wavefunction data into a format
            // consumed by Q#.
            var qSharpData = QSharpFormat.Convert.ToQSharpFormat(
                pauliHamiltonian.ToQSharpFormat(),
                wavefunction.ToQSharpFormat());

            // Invoke quantum simulator and run `GetEnergyByTrotterization` in the first
            // molecular Hydrogen sample.
            using (var qSim = new QuantumSimulator())
            {
                
                Console.WriteLine($"Estimating at bond length {idxBond}:");

                var (phaseEst, energyEst) = GetEnergyByTrotterization.Run(qSim, qSharpData, bitsOfPrecision, trotterStepSize, IntegratorOrder).Result;

                return (bondLength, energyEst);
            }
        }
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
            foreach (var idxBond in Enumerable.Range(0, LiHSimulation.problemData.Length))
            {
                var tst = LiHSimulation.problemData;
                var bondLength = Double.Parse(LiHSimulation.bondLengths[idxBond]);
                var hamData = LiHSimulation.problemData[idxBond];
                var energies = hamData.Wavefunctions.ToDictionary(o => o.Key, o => o.Value.Energy);
                var offset = hamData.EnergyOffset;
                foreach (var (k, v) in energies)
                {
                    var response = SerializeResponse(
                            "plotPoint",
                            new Dictionary<string, object>
                            {
                                { "source", k },
                                { "bondLength", bondLength },
                                { "theoreticalEnergy", v},
                            }
                        );
                    stream.Write(response, 0, response.Length);
                }
            }

            // Now plot simulation results               
            string[] states = new string[] { "|G>", "|E1>", "|E2>", "|E3>", "|E4>", "|E5>" };
            foreach (var state in states)
            {
                foreach (var idxBond in Enumerable.Range(0, LiHSimulation.problemData.Length))
                {
                    var (bondLength, energyEst) = LiHSimulation.GetSimulationResult(idxBond, state);


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
            // These are arguments that can be set from command line.
            var integratorOrder = 1L;
            var stepSize = 0.5;
            var bitsOfPrecision = 8L;
            var options = new OptionSet {
                { "o|integrator-order=", "Order of Trotter-Suzuki integrator", (Int64 o) => integratorOrder = o},
                { "s|step-size=", "Step size of Trotter-Suzuki integrator", (Double s) => stepSize = s},
                { "b|bits-precision=", "Bits of preicison in quantum phase estimation algorithm", (Int64 b) => bitsOfPrecision = b},
            };

            LiHSimulation.IntegratorOrder = integratorOrder;
            LiHSimulation.trotterStepSize = stepSize;
            LiHSimulation.bitsOfPrecision = bitsOfPrecision;

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
