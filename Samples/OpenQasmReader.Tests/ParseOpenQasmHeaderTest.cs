// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System.IO;
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class ParseOpenQasmHeaderTest
    {
        [Fact]
        public void HeaderWithPointCommaResultsNoCrash()
        {
            var input = "2.0;";
            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();
                Parser.ParseOpenQasmHeader(enumerator);

                //Expecting to end on the ';', so next loop can pick the next token
                Assert.Equal(";", enumerator.Current);
            }
        }

        [Fact]
        public void HeaderWithWrongVersionNoCrash()
        {
            var input = "3.0;";
            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();
                Parser.ParseOpenQasmHeader(enumerator);

                //Expecting to end on the ';', so next loop can pick the next token
                Assert.Equal(";", enumerator.Current);
            }
        }
    }
}
