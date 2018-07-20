// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using Microsoft.Quantum.Samples.OpenQasmReader.Tests.Properties;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class End2EndTest
    {
        const string TARGET_NAMESPACE = "Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate";

        [Fact]
        public void HadamardConversionTest()
        {
            TestConversion("HadamardTest.qs", Resources.Hadamard, Resources.HadamardResult);
        }

        [Fact]
        public void CNotConversionTest()
        {
            TestConversion("CNotTest.qs", Resources.CNot, Resources.CNotResult);
        }

        [Fact]
        public void FlipConversionTest()
        {
            TestConversion("FlipTest.qs", Resources.Flip, Resources.FlipResult);
        }

        private static void TestConversion(string name, string input, string expected)
        {
            var inputFile = Path.Combine(Path.GetTempPath(), name);
            try
            {
                //Write OpenQuasm program 
                File.WriteAllText(inputFile, input);

                //Transform
                var result = Parser.ConvertQasmFile(TARGET_NAMESPACE, inputFile);

                //Reformat result, so they can be compared (unix/windows and layout differences);
                expected = Regex.Replace(expected, @"\s+", " ").Trim().Trim(new char[] { '\uFEFF', '\u200B' }); ;
                result = Regex.Replace(result, @"\s+", " ").Trim().Trim(new char[] { '\uFEFF', '\u200B' }); ;

                Assert.Equal(expected, result);
            }
            finally
            {
                if (File.Exists(inputFile))
                {
                    File.Delete(inputFile);
                }
            }
        }
    }
}
