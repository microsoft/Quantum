// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Quantum.Simulation.Core;

namespace Qasm
{
    public class ConsoleDriver : QasmDriver
    {
        //Use 20 for now
        public override int QBitCount => 20;

        public override string Name => "Console";

        protected override IEnumerable<Result> RunQasm(StringBuilder quasm, int runs)
        {
            Console.WriteLine(quasm);
            //No measurement
            return Enumerable.Repeat(Result.Zero, QBitCount);
        }
    }
}
