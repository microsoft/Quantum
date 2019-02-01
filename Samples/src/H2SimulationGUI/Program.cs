// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Collections.Generic;
using Newtonsoft.Json;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Core;
using System.Runtime.InteropServices;
using System.Linq;

namespace Microsoft.Quantum.Samples.H2Simulation
{
    class ServerThread
    {

        private static readonly double[] theoryData = {
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
            using (var qsim = new QuantumSimulator())
            {
                // To call a Q# operation that takes unit `()` as its input, we need to grab
                // the QVoid.Instance value.
                var bondLengths = H2BondLengths.Run(qsim).Result;

                // In Q#, we defined the operation that performs the actual estimation; since the Q# operation
                // has type (idxBondLength : Int, nBitsPrecision : Int, trotterStepSize : Double) => (Double),
                // we pass the index along with that we want six bits of precision and
                // step size of 1.
                //
                // The result of calling H2EstimateEnergyRPE is a Double, so we can minimize over
                // that to deal with the possibility that we accidentally entered into the excited
                // state instead of the ground state of interest.
                Func<int, Double> estAtBondLength = (idx) => Enumerable.Min(
                    from idxRep in Enumerable.Range(0, 3)
                    select H2EstimateEnergyRPE.Run(qsim, idx, 6, 1.0).Result
                );

                // We are now equipped to run the Q# simulation at each bond length
                // and print the answers out to the console.
                foreach (var idxBond in Enumerable.Range(0, 54))
                {
                    System.Console.WriteLine($"Estimating at bond length {bondLengths[idxBond]}:");
                    var est = estAtBondLength(idxBond);
                    var response = SerializeResponse(
                        "plotPoint",
                        new Dictionary<string, object>
                        {
                                { "bondLength", bondLengths[idxBond] },
                                { "theoreticalEnergy", theoryData[idxBond] },
                                { "estEnergy", est }
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
                var port = 8001;
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
                Environment.GetEnvironmentVariable("PATH").Split(
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
            Environment.Exit(process.ExitCode);
        }
    }
}
