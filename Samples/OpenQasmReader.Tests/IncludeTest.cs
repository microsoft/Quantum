// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class IncludeTest
    {
        [Fact]
        public void MissingIncludeResultsMessageInComment()
        {
            var input = "include \"doesnotexist.inc\";";

            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();
                enumerator.MoveNext(); //include

                var cRegs = new Dictionary<string, int>();
                var qRegs = new Dictionary<string, int>();
                var inside = new StringBuilder();
                var outside = new StringBuilder();
                var conventionalMeasured = new List<string>();
                Parser.ParseInclude(enumerator, cRegs, qRegs, "path", inside, outside, conventionalMeasured);

                //Expecting to end on the ';', so next loop can pick the next token
                Assert.Equal(";", enumerator.Current);
                //no traditional cRegisters
                Assert.Equal(new string[0], cRegs.Keys);
                Assert.Equal(new int[0], cRegs.Values);
                //No quantum registers
                Assert.Equal(new string[0], qRegs.Keys);
                Assert.Equal(new int[0], qRegs.Values);
                //No output within the method
                Assert.Equal(string.Empty, inside.ToString());

                //Expected operation
                Assert.Equal("//Generated without includes of path\\doesnotexist.inc because the file was not found during generation.",
                    outside.ToString().Trim()
                        .Replace("\n", string.Empty)
                        .Replace("\r", string.Empty)
                        .Replace(Parser.INDENTED, string.Empty)
                        .Replace("  ", string.Empty));
            }
        }
    }
}
