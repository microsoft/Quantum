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
    public class ParseConditionTest
    {
        readonly string[] TestEndMarker = new string[] { ")" };

        [Fact]
        public void ParseConditionNumberTestResultsIsNumberTest()
        {
            var input = "1==1)";
            string result = null;
            var cRegs = new Dictionary<string, int>();
            result = ParseCondition(input, cRegs, TestEndMarker);
            Assert.Equal("1==1", result);
        }

        [Fact]
        public void ParseConditionCregNumberTestResultsNumberConversionTest()
        {
            var input = "1==a)";
            string result = null;
            var cRegs = new Dictionary<string, int>() { { "a", 1 } };
            result = ParseCondition(input, cRegs, TestEndMarker);
            Assert.Equal("1==ResultAsInt(a)", result);
        }

        [Fact]
        public void ParseConditionCregPiTestResultsPiConversionTest()
        {
            var input = "pi<q_1)";
            string result = null;
            var cRegs = new Dictionary<string, int>() { { "q_1", 1 } };
            result = ParseCondition(input, cRegs, TestEndMarker);
            Assert.Equal("PI()<ResultAsInt(q_1)", result);
        }

        [Fact]
        public void ParseConditionNestedTestResultsNestedTest()
        {
            var input = "(3+6)==9)";
            string result = null;
            var cRegs = new Dictionary<string, int>() { { "q_1", 1 } };
            result = ParseCondition(input, cRegs, TestEndMarker);
            Assert.Equal("(3+6)==9", result);
        }

        [Fact]
        public void ParseConditionDeepNestedTestResultsDeepNestedTest()
        {
            var input = "(3+(6-2))!=9)";
            string result = null;
            var cRegs = new Dictionary<string, int>() { { "q_1", 1 } };
            result = ParseCondition(input, cRegs, TestEndMarker);
            Assert.Equal("(3+(6-2))!=9", result);
        }


        /// <summary>
        /// Helper function top execute ParseCalculation Method
        /// </summary>
        /// <param name="input">Test file</param>
        /// <param name="cRegs">Traditional register</param>
        /// <param name="endmarkers">Markers to stop on</param>
        /// <returns>resultstring</returns>
        private static string ParseCondition(string input, Dictionary<string,int> cRegs, params string[] endmarkers)
        {
            string result;
            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();
                enumerator.MoveNext();
                result = Parser.ParseCondition(enumerator, cRegs, endmarkers);
            }

            return result;
        }
    }
}
