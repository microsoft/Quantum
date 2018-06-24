﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class HeaderParserTest
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
    }
}
