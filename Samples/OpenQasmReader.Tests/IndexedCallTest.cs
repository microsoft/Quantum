// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class IndexedCallTest
    {
        [Fact]
        public void IndexedCallLoopWhenRequiredWithoutIndex()
        {
            Assert.Equal("q[_idx]", Parser.IndexedCall("q", true));
        }

        [Fact]
        public void IndexedCallLoopWhenRequiredWithIndex()
        {
            Assert.Equal("q[3]", Parser.IndexedCall("q[3]", true));
        }

        [Fact]
        public void IndexedCallLoopWhenNotRequiredWithoutIndex()
        {
            Assert.Equal("q", Parser.IndexedCall("q", false));
        }

        [Fact]
        public void IndexedCallLoopWhenMotRequiredWithIndex()
        {
            Assert.Equal("q[3]", Parser.IndexedCall("q[3]", false));
        }
    }
}
