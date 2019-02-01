// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class FirstLetterToUpperCaseTest
    {
        [Fact]
        public void UpperCaseResultsUpperCase()
        {
            Assert.Equal("Abc", Parser.FirstLetterToUpperCase("Abc"));
        }

        [Fact]
        public void LowerResultsUpperCase()
        {
            Assert.Equal("Abc", Parser.FirstLetterToUpperCase("abc"));
        }

        [Fact]
        public void NumberResultsNumber()
        {
            Assert.Equal("1bc", Parser.FirstLetterToUpperCase("1bc"));
        }

        [Fact]
        public void SymbolResultsSymbol()
        {
            Assert.Equal(";bc", Parser.FirstLetterToUpperCase(";bc"));
        }

        [Fact]
        public void EmptyResultsEmpty()
        {
            Assert.Equal(string.Empty, Parser.FirstLetterToUpperCase(string.Empty));
        }

        [Fact]
        public void NullResultsEmpty()
        {
            Assert.Equal(string.Empty, Parser.FirstLetterToUpperCase(null));
        }
    }
}
