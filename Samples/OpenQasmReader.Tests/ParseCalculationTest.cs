// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System.IO;
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class ParseCalculationTest
    {
        readonly string[] TestEndMarker = new string[] { ";" };

        [Fact]
        public void ParseCalculationNumberResultsIsDecimal()
        {
            var input = "1;";
            string result = null;
            result = ParseCalculation(input, TestEndMarker);
            Assert.Equal("1.0", result);
        }

        [Fact]
        public void ParseCalculationPiResultsIsMethod()
        {
            var input = "pi;";
            string result = null;
            result = ParseCalculation(input, TestEndMarker);
            Assert.Equal("PI()", result);
        }

        [Fact]
        public void ParseCalculationAddResultsIsAddFormula()
        {
            var input = "1+3;";
            string result = null;
            result = ParseCalculation(input, TestEndMarker);
            Assert.Equal("1.0+3.0", result);
        }

        [Fact]
        public void ParseCalculationLargeMinusResultsIsMinusFormula()
        {
            var input = "12345678-90;";
            string result = null;
            result = ParseCalculation(input, TestEndMarker);
            Assert.Equal("12345678.0-90.0", result);
        }

        [Fact]
        public void ParseCalculationPiDivideResultsIsPiDivide()
        {
            var input = "pi/2;";
            string result = null;
            result = ParseCalculation(input, TestEndMarker);
            Assert.Equal("PI()/2.0", result);
        }

        [Fact]
        public void ParseCalculationParenthesesResultsParentheses()
        {
            var input = "14+(3/1)*13;";
            string result = null;
            result = ParseCalculation(input, TestEndMarker);
            Assert.Equal("14.0+(3.0/1.0)*13.0", result);
        }

        [Fact]
        public void ParseCalculationFirstEndMarkerResultsRestIgnore()
        {
            var input = "19;13)";
            string result = null;
            result = ParseCalculation(input, new string[]{ ";", ")"});
            Assert.Equal("19.0", result);
        }

        [Fact]
        public void ParseCalculationSecondEndMarkerResultsRestIgnore()
        {
            var input = "19)13;";
            string result = null;
            result = ParseCalculation(input, new string[] { ";", ")" });
            Assert.Equal("19.0", result);
        }

        [Fact]
        public void ParseCalculationNoEndMarkerResultsNotIgnore()
        {
            var input = "19-13;";
            string result = null;
            result = ParseCalculation(input, new string[] { ";", ")" });
            Assert.Equal("19.0-13.0", result);
        }

        [Fact]
        public void ParseCalculationReferencesResultsReferences()
        {
            var input = "q_1+5/14-q[12];";
            string result = null;
            result = ParseCalculation(input, TestEndMarker);
            Assert.Equal("q_1+5.0/14.0-q[12]", result);
        }

        [Fact]
        public void ParseCalculationScientificResultsScientific()
        {
            var input = "5.85167231706864e-9;";
            string result = null;
            result = ParseCalculation(input, TestEndMarker);
            Assert.Equal("5.85167231706864e-9", result);
        }

        /// <summary>
        /// Helper function top execute ParseCalculation Method
        /// </summary>
        /// <param name="input">Test file</param>
        /// <param name="endmarkers">Markers to stop on</param>
        /// <returns>resultstring</returns>
        private static string ParseCalculation(string input, params string[] endmarkers)
        {
            string result;
            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();
                enumerator.MoveNext();
                result = Parser.ParseCalculation(enumerator, endmarkers);
            }

            return result;
        }
    }
}
