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
    public class ParseIncludeTest
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
                var qubitMeasured = new List<string>();
                Parser.ParseInclude(enumerator, cRegs, qRegs, "path", inside, outside, conventionalMeasured, qubitMeasured);

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

                var path = Path.Combine("path", "doesnotexist.inc");

                //Expected operation
                Assert.Equal(string.Format("//Generated without includes of {0} because the file was not found during generation.", path),
                    outside.ToString().Trim()
                        .Replace("\n", string.Empty)
                        .Replace("\r", string.Empty)
                        .Replace("  ", string.Empty));
            }
        }

        [Fact]
        public void CorrectIncludeResultsInIncludedCode()
        {
            var fileName = Guid.NewGuid().ToString();

            try
            {
                File.WriteAllText(fileName, "qreg q[1];");

                var input = string.Format("include \"{0}\";", fileName);

                using (var stream = new StringReader(input))
                {
                    var enumerator = Parser.Tokenizer(stream).GetEnumerator();
                    enumerator.MoveNext(); //include

                    var cRegs = new Dictionary<string, int>();
                    var qRegs = new Dictionary<string, int>();
                    var inside = new StringBuilder();
                    var outside = new StringBuilder();
                    var conventionalMeasured = new List<string>();
                    var qubitMeasured = new List<string>();
                    Parser.ParseInclude(enumerator, cRegs, qRegs, ".", inside, outside, conventionalMeasured, qubitMeasured);

                    //Expecting to end on the ';', so next loop can pick the next token
                    Assert.Equal(";", enumerator.Current);
                    //no traditional cRegisters
                    Assert.Equal(new string[0], cRegs.Keys);
                    Assert.Equal(new int[0], cRegs.Values);
                    //we now have quantum Registers
                    Assert.Equal(new string[] { "q" }, qRegs.Keys);
                    Assert.Equal(new int[] { 1 }, qRegs.Values);
                    //No output within the method or outside
                    Assert.Equal(string.Empty, inside.ToString());
                    Assert.Equal(string.Empty, outside.ToString());
                }
            }
            finally
            {
                File.Delete(fileName);
            }
        }

        [Fact]
        public void IncludeEmptyFileResultsInIgnoredCode()
        {
            var fileName = Guid.NewGuid().ToString();

            try
            {
                File.WriteAllText(fileName, string.Empty);

                var input = string.Format("include \"{0}\";", fileName);

                using (var stream = new StringReader(input))
                {
                    var enumerator = Parser.Tokenizer(stream).GetEnumerator();
                    enumerator.MoveNext(); //include

                    var cRegs = new Dictionary<string, int>();
                    var qRegs = new Dictionary<string, int>();
                    var inside = new StringBuilder();
                    var outside = new StringBuilder();
                    var conventionalMeasured = new List<string>();
                    var qubitMeasured = new List<string>();
                    Parser.ParseInclude(enumerator, cRegs, qRegs, ".", inside, outside, conventionalMeasured, qubitMeasured);

                    //Expecting to end on the ';', so next loop can pick the next token
                    Assert.Equal(";", enumerator.Current);
                    //no traditional cRegisters
                    Assert.Equal(new string[0], cRegs.Keys);
                    Assert.Equal(new int[0], cRegs.Values);
                    //no quantum Registers
                    Assert.Equal(new string[0], cRegs.Keys);
                    Assert.Equal(new int[0], cRegs.Values);
                    //No output within the method or outside
                    Assert.Equal(string.Empty, inside.ToString());
                    Assert.Equal(string.Empty, outside.ToString());
                }
            }
            finally
            {
                File.Delete(fileName);
            }
        }


    }
}
