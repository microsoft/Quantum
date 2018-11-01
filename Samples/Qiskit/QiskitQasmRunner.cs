// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using System.IO;
using System.Runtime.InteropServices;

namespace Microsoft.Quantum.Samples.Qiskit
{
    /// <summary>
    /// Quick version to transfer to python in a real linux environment, because Qiskit doesn't run on the windows python
    /// </summary>
    internal static class QiskitExecutor
    {
        /// <summary>
        /// Use the linux subsystem, to run in a real linux and run the python code to execute the Qasm
        /// </summary>
        public static string RunQasm(StringBuilder qasm, int qbits, string key, string backend, int shots)
        {
            try
            {
                var input = "input.txt";
                var output = "output.txt";

                //Change to unix compatible file format
                File.WriteAllText(input, qasm.ToString().Replace("\r\n", "\n"), Encoding.ASCII);

                //Run python3 with the interface
                var python = "python3";
                var arguments = $"QiskitInterface.py {key} {backend} {shots}";

                //HACK: fix because currently qiskit currently can't run directly within windows, 
                //      so wrap it in linux subsystem of bash
                if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                {
                    python = "bash.exe";
                    arguments = $"-c \"python3 {arguments}\"";
                }

                var processStart = new ProcessStartInfo()
                {
                    FileName = python,
                    Arguments = arguments,
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                };
                var process = new Process()
                {
                    StartInfo = processStart,
                    EnableRaisingEvents = true
                };
                process.OutputDataReceived += (p, o) => Console.WriteLine(o.Data);
                process.ErrorDataReceived += (p, o) => Console.Error.WriteLine(o.Data);
                process.Start();
                process.BeginErrorReadLine();
                process.BeginOutputReadLine();
                process.WaitForExit();

                if (File.Exists(output))
                {
                    var result = File.ReadAllText(output);
                    if (result.Contains("'labels':"))
                    {
                        result = result.Substring(result.IndexOf("'labels': ['") + 12, qbits);
                    }
                    return result;
                }
                else
                {
                    Console.WriteLine("Missing output in outputfile");
                    return "";
                }
            }
            catch (Exception e)
            {
                Console.WriteLine($"Starting QiskitInterface.py failed because of: {e.Message}");
                return "";
            }
        }
    }
}
