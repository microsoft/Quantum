// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Qasm;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Qiskit
{
    abstract class QiskitDriver : QasmDriver
    {
        public QiskitDriver(string key): base()
        {
            Key = key;
        }
        public string Key { get; set; }

        protected override IEnumerable<Result> RunQasm(StringBuilder quasm, int runs)
        {
            Console.WriteLine("");
            Console.WriteLine("QUASM file");
            Console.Write(quasm.ToString());
            Console.WriteLine("");

            string result = QiskitExecutor.RunQuasm(quasm, QBitCount, Key, Name, runs);
            Console.WriteLine("Processed");
            if (result.Length != QBitCount)
            {
                Console.WriteLine("Wrong measurement count. Offline ?");
                return new List<Result>() { Result.Zero, Result.Zero, Result.Zero, Result.Zero, Result.Zero };
            }
            Console.WriteLine("Result=" + result);
            return result.Select(c => c == '1' ? Result.One : Result.Zero)
                .Reverse().ToList();
        }
    }
}
