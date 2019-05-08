// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System.IO;
using System.Linq;
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class TokenizerTest
    {
        [Fact]
        public void EmptyFileResultsNoTokens()
        {
            var input = string.Empty;
            string[] result = null;
            result = Tokenize(input);
            Assert.Empty(result);
        }

        [Fact]
        public void CommentOnlyResultsNoTokens()
        {
            var input = "//H q1";
            string[] result = null;
            result = Tokenize(input);
            Assert.Empty(result);
        }

        [Fact]
        public void WhiteCharactersResultsNoTokens()
        {
            var input =  "\t\n\r\v     ";
            string[] result = null;
            result = Tokenize(input);
            Assert.Empty(result);
        }

        [Fact]
        public void CommentsRecognizeUnixLineEndingResultsTokens()
        {
            var input = "before\n//H\nafter";
            string[] result = null;
            result = Tokenize(input);
            Assert.Equal(new string[] { "before", "after" }, result);
        }

        [Fact]
        public void CommentsRecognizeWindowsLineEndingResultsTokens()
        {
            var input = "before\r\n//H\r\nafter";
            string[] result = null;
            result = Tokenize(input);
            Assert.Equal(new string[]{ "before", "after"}, result);
        }

        [Fact]
        public void NonCommentSpecialCharacterResultsTokens()
        {
            // Starting with the '/' instead of "//"
            var input = "/(){},;+-*=!<>a";
            string[] result = null;
            result = Tokenize(input);
            Assert.Equal(input.Select(c => "" + c), result);
        }

        [Fact]
        public void NonCommentReferenceResultsTokens()
        {
            //Not valid QASM, but extreme case
            var input = "6/pi/[11.12+14]/q_1";
            string[] result = null;
            result = Tokenize(input);
            Assert.Equal(new string[] {
                "6", "/", "pi", "/", "[11.12",
                "+", "14]", "/", "q_1" }
                , result);
        }

        [Fact]
        public void SimpleFormulaResultsTokens()
        {
            var input = "1+16-(4/3)*14";
            string[] result = null;
            result = Tokenize(input);
            Assert.Equal(new string[] {
                "1", "+", "16", "-",
                "(", "4", "/", "3",
                ")", "*", "14" }
                , result);
        }

        [Fact]
        public void SimpleGateCallResultsTokens()
        {
            var input = "RGate(14.12) q1[3],q_2;";
            string[] result = null;
            result = Tokenize(input);
            Assert.Equal(new string[] {
                "RGate", "(", "14.12", ")",
                "q1[3]", ",", "q_2", ";" }
                , result);
        }

        [Fact]
        public void SpecialCharacterResultsTokens()
        {
            var input = "(){},;+-*=!<>a";
            string[] result = null;
            result = Tokenize(input);
            Assert.Equal(input.Select(c => "" +c), result);
        }

        /// <summary>
        /// Helper function to test the tokenizer
        /// </summary>
        /// <param name="input">String to use as input</param>
        /// <returns>Tokens</returns>
        private static string[] Tokenize(string input)
        {
            string[] result;
            using (var stream = new StringReader(input))
            {
                result = Parser.Tokenizer(stream).ToArray();
            }

            return result;
        }
    }
}
