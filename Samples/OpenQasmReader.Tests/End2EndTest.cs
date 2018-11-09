// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class End2EndTest
    {
        const string SOURCE_NAMESPACE = "Microsoft.Quantum.Samples.OpenQasmReader.Tests.TestFunctions";
        const string TARGET_NAMESPACE = "Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate";

        [Fact]
        public void HadamardConversionTest() => TestConversion("Hadamard.qs", $"{SOURCE_NAMESPACE}.Hadamard.qasm", $"{TARGET_NAMESPACE}.Hadamard.qs");

        [Fact]
        public void CNotConversionTest() => TestConversion("CNot.qs", $"{SOURCE_NAMESPACE}.CNot.qasm", $"{TARGET_NAMESPACE}.CNot.qs");

        [Fact]
        public void GatesConversionTest() => TestConversion("Gates.qs", $"{SOURCE_NAMESPACE}.Gates.qasm", $"{TARGET_NAMESPACE}.Gates.qs");

        [Fact]
        public void FiveQubitEncodingConversionTest() => TestConversion("FiveQubit1.qs", $"{SOURCE_NAMESPACE}.5qubit1.qasm", $"{TARGET_NAMESPACE}.FiveQubit1.qs");

        [Fact]
        public void BernsteinVaziraniConversionTest() => TestConversion("bv3.qs", $"{SOURCE_NAMESPACE}.bv3.qasm", $"{TARGET_NAMESPACE}.Bv3.qs");
        [Fact]
        public void HiddenShiftConversionTest() => TestConversion("hid3.qs", $"{SOURCE_NAMESPACE}.hid3.qasm", $"{TARGET_NAMESPACE}.Hid3.qs");
        [Fact]
        public void MargolusConversionTest() => TestConversion("marg5.qs", $"{SOURCE_NAMESPACE}.marg5.qasm", $"{TARGET_NAMESPACE}.Marg5.qs");
        [Fact]
        public void ToffoliConversionTest() => TestConversion("toff6.qs", $"{SOURCE_NAMESPACE}.toff6.qasm", $"{TARGET_NAMESPACE}.Toff6.qs");

        private const string CommonOpenQasmIncludeFile = "qelib1.inc";

        private static void TestConversion(string name, string inputResourceName, string expectedResourceName)
        {
            var input = ReadResource(inputResourceName);
            var expected = ReadResource(expectedResourceName); ;

            var inputFile = Path.Combine(Path.GetTempPath(), name);
            var dummyInclude = Path.Combine(Path.GetTempPath(), CommonOpenQasmIncludeFile);
            try
            {
                //Write OpenQasm program 
                File.WriteAllText(inputFile, input);
                File.WriteAllText(dummyInclude, "gate cx a,b { CX a,b; }");

                //Transform
                var result = Parser.ConvertQasmFile(TARGET_NAMESPACE, inputFile);

                //Reformat result, so they can be compared (unix/windows, layout differences, and copyright headers);
                expected = Regex.Replace(expected, @"\s+", " ").Trim().Trim(new char[] { '\uFEFF', '\u200B' });
                result = COPYRIGHTHEADER.Replace("\n", Environment.NewLine) + result;
                result = Regex.Replace(result, @"\s+", " ").Trim().Trim(new char[] { '\uFEFF', '\u200B' }); ;

                Assert.Equal(expected, result);
            }
            finally
            {
                if (File.Exists(inputFile))
                {
                    File.Delete(inputFile);
                }
                if (File.Exists(dummyInclude))
                {
                    File.Delete(dummyInclude);
                }
            }
        }

        private static string ReadResource(string resourceName)
        {
            var assembly = Assembly.GetExecutingAssembly();
            using (var stream = assembly.GetManifestResourceStream(resourceName))
            {
                if (stream == null)
                {
                    throw new Exception($"Resource {resourceName} not found in {assembly.FullName}.  Valid resources are: {String.Join(", ", assembly.GetManifestResourceNames())}.");
                }
                using (var reader = new StreamReader(stream))
                {
                    return reader.ReadToEnd();
                }
            }
        }

        private const string COPYRIGHTHEADER = "// Copyright (c) Microsoft Corporation. All rights reserved.\n// Licensed under the MIT License.\n";
    }
}
