using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using System.IO;

namespace Quasm.Qiskit
{
    /// <summary>
    /// Quick version to tranfer to python in a real linux environment, because Qiskit doesn't run on the windows python
    /// </summary>
    internal static class QiskitExecutor
    {
        /// <summary>
        /// Use the linux subsystem, to run in a real linux and run the python code to execute the Quasm
        /// </summary>
        public static string RunQuasm(StringBuilder quasm, int qbits, string key, string backend)
        {
            try
            {
                File.WriteAllText("Qiskit\\data.txt", quasm.ToString().Replace("\r\n", "\n"), Encoding.ASCII);

                string result = null;

                var processStart = new ProcessStartInfo()
                {
                    FileName = "bash",
                    Arguments = $"-c \"python3 QiskitInterface.py {key} {backend}\"",
                    WorkingDirectory = "Qiskit",
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                };
                var process = Process.Start(processStart);
                while (!process.StandardOutput.EndOfStream)
                {
                    string line = process.StandardOutput.ReadLine();

                    Console.WriteLine(line);
                    if (line.Contains("'labels':"))
                    {
                        result = line.Substring(line.IndexOf("'labels': ['") + 12, qbits);
                    }
                }
                Console.WriteLine(process.StandardError.ReadToEnd());
                return result ?? "";
            }
            catch (Exception)
            {
                return "";
            }
        }
    }
}
