// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System.Collections.Generic;
using System.IO;
using System.Text;
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class ParseBarrierTest
    {

        [Fact]
        public void ParseBarrierSingleQubitTest()
        {
            var input = "barrier q[0];";
            string result = null;
            var qRegs = new Dictionary<string, int>();
            result = ParseBarrier(input, qRegs);
            Assert.Equal(";", result);
        }

        [Fact]
        public void ParseBarrierTwoQubitTest()
        {
            var input = "barrier q[0],q[1];";
            string result = null;
            var qRegs = new Dictionary<string, int>();
            result = ParseBarrier(input, qRegs);
            Assert.Equal(";", result);
        }

        [Fact]
        public void ParseBarrierMultipleQubitTest()
        {
            var input = "barrier q[0],q[1],q[2],q[3],q[4],q[5],q[6];";
            string result = null;
            var qRegs = new Dictionary<string, int>();
            result = ParseBarrier(input, qRegs);
            Assert.Equal(";", result);
        }

        [Fact]
        //Parser issue of #58 where barrier parsed to much
        public void ParseBarrierMultipleQubitOpenTest()
        {
            var input = "barrier q[0],q[1],q[2],q[3],q[4],q[5],q[6];othergate";
            string result = null;
            var qRegs = new Dictionary<string, int>();
            result = ParseBarrier(input, qRegs);
            Assert.Equal(";", result);
        }

        [Fact]
        public void ParseBarrierRegisterTest()
        {
            var input = "barrier q;";
            string result = null;
            var qRegs = new Dictionary<string, int>();
            result = ParseBarrier(input, qRegs);
            Assert.Equal(";", result);
        }

        /// <summary>
        /// Helper function top execute ParseBarrier Method
        /// </summary>
        /// <param name="input">Test file</param>
        /// <returns>resultstring</returns>
        private static string ParseBarrier(string input, Dictionary<string, int> qRegs)
        {
            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();
                enumerator.MoveNext();
                Parser.ParseBarrier(enumerator, qRegs);
                return enumerator.Current;
            }
        }
    }
}
