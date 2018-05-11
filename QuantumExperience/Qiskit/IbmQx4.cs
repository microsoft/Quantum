// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Quasm;
using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;

namespace Quasm.Qiskit
{
    /*
     * Quick and dirty driver to enable the IbmQx4
     */
    public class IbmQx4 : QuasmDriver
    {
        public IbmQx4(string key)
        {
            Key = key;
        }

        public string Key { get; set; }

        public override int QBitCount => 5;

        public override string Name => "IbmQx4";

        protected override List<Result> RunQuasm(StringBuilder quasm, int runs)
        {
            string result = QiskitExecutor.RunQuasm(quasm, QBitCount, Key, "ibmqx4", runs);
            Console.WriteLine("Processed");
            if (result.Length != QBitCount)
            {
                Console.WriteLine("Wrong measurement count. Offline ?");
                return new List<Result>() { Result.Zero, Result.Zero , Result.Zero , Result.Zero , Result.Zero };
            }
            Console.WriteLine("Result=" + result);
            return result.Select(c => c == '1' ? Result.One : Result.Zero)
                .Reverse().ToList();
        }
    }
}
