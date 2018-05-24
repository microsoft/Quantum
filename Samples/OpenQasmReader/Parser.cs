// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Microsoft.Quantum.Samples.OpenQasmReader
{
    /// <summary>
    /// A quick and simple qasm parser and Q# generator which was hand roled to remain under MIT license
    /// </summary>
    public class Parser
    {
        /// <summary>
        /// Main runner
        /// Usage: Application <Namespace/> <Filename/>
        /// </summary>
        /// <param name="args"></param>
        public static void Main(string[] args)
        {
            if (args.Length != 2)
            {
                Console.WriteLine("QASM to Q# Conversion tool");
                Console.WriteLine("Usage <namespace> <filename>");
                Console.WriteLine("Example: Quantum.Imported adder.qasm");
            }
            else
            {
                Console.Write(ConvertQasmFile(args[0], args[1]));
            }
        }

        /// <summary>
        /// Convert the qasm file to Q#
        /// </summary>
        /// <param name="ns">Namespace of the Q# to be under</param>
        /// <param name="path">Path of the Qasm file</param>
        /// <returns>Q# file content</returns>

        public static string ConvertQasmFile(string ns, string path)
        {
            using (var file = File.OpenText(path))
            {
                return ParseMain(Tokenizer(file).GetEnumerator(), ns, Path.GetFileNameWithoutExtension(path), Path.GetDirectoryName(path));
            }
        }

        /// <summary>
        /// Parses the main qasm file
        /// Responsible for emitting the top method
        /// </summary>
        /// <param name="token">Current token of the tokenizer</param>
        /// <param name="ns">Namespace to generate the Q# file in</param>
        /// <param name="name">Name of the file, which results in the operation name</param>
        /// <param name="path">Directory the qasm is located in (mostly for include purposes)</param>
        /// <returns>Q# file content</returns>
        public static string ParseMain(IEnumerator<string> token, string ns, string name, string path)
        {
            var conventionalMeasured = new List<string>();
            var qRegs = new Dictionary<string, int>();
            var cRegs = new Dictionary<string, int>();
            var inside = new StringBuilder();
            var outside = new StringBuilder();
            ParseApplication(token, cRegs, qRegs, path, inside, outside, conventionalMeasured);

            var result = new StringBuilder(inside.Length + outside.Length);
            result.AppendFormat(HEADER, ns);
            result.Append(outside.ToString());
            WriteOperation(result, cRegs, qRegs, name, new string[]{ }, conventionalMeasured, inside);
            result.Append(TAIL);
            return result.ToString();
        }

        /// <summary>
        /// Parses the Qasm application and componenents
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="cRegs">Conventional registers defined</param>
        /// <param name="qRegs">Quantum registers defined</param>
        /// <param name="path">Directory the qasm is located in (mostly for include purposes)</param>
        /// <param name="inside">Stream to write within the current operation being parsed</param>
        /// <param name="outside">Stream to write outside the current operation being parsed (mostly for defining side operations)</param>
        /// <param name="conventionalMeasured">Currently measured conventional registers (mostly used for output)</param>
        private static void ParseApplication(IEnumerator<string> token, Dictionary<string, int> cRegs, Dictionary<string, int> qRegs, string path, StringBuilder inside, StringBuilder outside, List<string> conventionalMeasured)
        {while (token.MoveNext())
            {
                switch (token.Current)
                {
                    case "OPENQASM":
                        ParseOpenQasmHeader(token);
                        break;
                    case "include":
                        ParseInclude(token, cRegs, qRegs, path, inside, outside, conventionalMeasured);
                        break;
                    case "gate":
                        ParseGateSpecification(token, path, outside);
                        break;
                    case "qreg":
                        ParseQuantumRegister(token, qRegs);
                        break;
                    case "creg":
                        ParseConventionalRegister(token, cRegs, inside);
                        break;
                    case "U":
                        ParseUGate(token, inside);
                        break;
                    case "x":
                        ParseOneGate(token, "X", qRegs, inside);
                        break;
                    case "y":
                        ParseOneGate(token, "Y", qRegs, inside);
                        break;
                    case "z":
                        ParseOneGate(token, "Z", qRegs, inside);
                        break;
                    case "H":
                    case "h":
                        ParseOneGate(token, "H", qRegs, inside);
                        break;
                    case "s":
                        ParseOneGate(token, "S", qRegs, inside);
                        break;
                    case "sdg":
                        ParseOneGate(token, "(Adjoint S)", qRegs, inside);
                        break;
                    case "t":
                        ParseOneGate(token, "T", qRegs, inside);
                        break;
                    case "tdg":
                        ParseOneGate(token, "(Adjoint T)", qRegs, inside);
                        break;
                    case "id":
                        ParseOneGate(token, "I", qRegs, inside);
                        break;
                    case "CX":
                    case "cx":
                        ParseTwoGate(token, "CNOT", qRegs, inside);
                        break;
                    case "ccx":
                        ParseThreeGate(token, "CCNOT", qRegs, inside);
                        break;
                    case "measure":
                        ParseMeasure(token, inside, cRegs, qRegs, conventionalMeasured);
                        break;
                    case CLOSE_CURLYBRACKET:
                        return;
                    case POINT_COMMA:
                        break;
                    default:
                        ParseGateCall(token, inside, qRegs);
                        break;
                }
            }
        }

        /// <summary>
        /// Register a conventional (Result) register
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="cRegs">Conventional registers defined</param>
        /// <param name="path">Directory the qasm is located in (mostly for inlcude purposes)</param>
        private static void ParseConventionalRegister(IEnumerator<string> token, Dictionary<string, int> cRegs, StringBuilder inside)
        {
            token.MoveNext();
            var name = token.Current;
            var index = name.IndexOf('[') + 1;
            var count = int.Parse(name.Substring(index, name.IndexOf(']') - index));
            name = name.Remove(index - 1);
            cRegs.Add(name, count);
            
            token.MoveNext(); //;
        }

        private static void ParseQuantumRegister(IEnumerator<string> token, Dictionary<string, int> qRegs)
        {
            token.MoveNext();
            var name = token.Current;
            var index = name.IndexOf('[') +1;
            var count = int.Parse(name.Substring(index, name.IndexOf(']') - index));
            qRegs.Add(name.Remove(index-1), count);
            token.MoveNext(); //;
        }

        private static void ParseGateCall(IEnumerator<string> token, StringBuilder builder, Dictionary<string,int> qReg)
        {
            var gateName = token.Current;
            var doubles = new List<string>();
            var qbits = new List<string>();
            bool withinParentheses = false;
            while (token.MoveNext() && !token.Current.Equals(POINT_COMMA))
            {
                if (token.Current.Equals(COMMA))
                {
                    continue;
                }
                else if (token.Current.Equals(OPEN_PARANTHESES))
                {
                    withinParentheses = true;
                }
                else if (token.Current.Equals(CLOSE_PARANTHESES))
                {
                    withinParentheses = false;
                }
                else if (withinParentheses)
                {
                    doubles.Add(ParseCalulation(token, COMMA, CLOSE_PARANTHESES));
                    if (token.Current.Equals(CLOSE_PARANTHESES))
                    {
                        withinParentheses = false;
                    }
                }
                else
                {
                    qbits.Add(token.Current);
                }
            }

            var loopRequired = qReg.Count != 0 && qbits.Any() && !qbits.Any(q => q.Contains('['));
            if (loopRequired)
            {
                builder.Append(INDENTED);
                var size = qbits.First(q => !q.Contains('['));
                builder.AppendFormat("for(_idx in 0..Length({0})){{\n", size);
                builder.Append("    ");
            }
            builder.Append(INDENTED);
            builder.Append(FirstLetterToUpperCase(gateName));
            builder.Append('(');
            var types = doubles.Concat(qbits.Select(qbit => !loopRequired || qbit.Contains('[') ? qbit : string.Format("{0}[_idx]", qbit)));
            builder.Append(string.Join(COMMA, types));
            builder.AppendLine(");");
            if (loopRequired)
            {
                builder.Append(INDENTED);
                builder.AppendLine("}");
            }
        }

        private static void ParseOneGate(IEnumerator<string> token, string gate, Dictionary<string, int> qReg, StringBuilder builder)
        {
            token.MoveNext();
            var q1 = token.Current;
            token.MoveNext(); // ;
            builder.Append(INDENTED);
            if (qReg.Count == 0 ||  q1.Contains('['))
            {
                builder.AppendFormat("{0}({1});\n", gate, q1);
            }
            //Implicit expansion
            else
            {
                builder.AppendFormat("ApplyToEach({0},{1});\n", gate, q1);
            }
        }

        private static void ParseTwoGate(IEnumerator<string> token, string gate, Dictionary<string, int> qReg,StringBuilder builder)
        {
            token.MoveNext();
            var q1 = token.Current;
            token.MoveNext(); // ,
            token.MoveNext();
            var q2 = token.Current;
            token.MoveNext(); // ;
            builder.Append(INDENTED);
            if (qReg.Count == 0 || (q1.Contains('[') && q2.Contains('[')))
            {
                builder.AppendFormat("{0}({1},{2});\n", gate, q1, q2);
            }
            else
            {
                var index = q1.IndexOf('[');
                var size = index < 0 ? q2 : q1.Remove(index);
                builder.AppendFormat("for(_idx in 0..Length({0})){{\n", size);
                builder.Append(INDENTED);
                builder.AppendFormat("{0}({1},{2});\n", gate, 
                    q1.Contains('[') ? q1 : string.Format("{0}[_idx]", q1), 
                    q2.Contains('[') ? q2 : string.Format("{0}[_idx]", q2));
                builder.Append(INDENTED);
                builder.AppendLine("}");
            }
        }

        private static void ParseMeasure(IEnumerator<string> token, StringBuilder builder, Dictionary<string, int> cReg, Dictionary<string, int> qReg, List<string> conventionalMeasured)
        {
            token.MoveNext();
            var q1 = token.Current;
            token.MoveNext(); // -
            token.MoveNext();
            var q3 = token.Current;
            token.MoveNext(); // 

            var loopRequired = qReg.Count != 0 && !(q1.Contains('[') && q3.Contains('['));
            if (loopRequired)
            {
                builder.Append(INDENTED);
                var index = q1.IndexOf('[');
                var size = index < 0 ? q3 : q1.Remove(index);
                builder.AppendFormat("for(_idx in 0..Length({0})){{\n", size);
                builder.Append("    ");
            }
            builder.Append(INDENTED);
            var measured = q3.Contains('[') ? q3 : string.Format("{0}[_idx]", q3);
            builder.AppendFormat("set {1} = M({0});\n", !loopRequired || q1.Contains('[') ? q1 : string.Format("{0}[_idx]", q1), measured);
            if (loopRequired)
            {
                builder.Append(INDENTED);
                builder.AppendLine("}");
            }

            if (q3.Contains('['))
            {
                if (!conventionalMeasured.Contains(q3)) { conventionalMeasured.Add(q3); }
            }
            else
            {
                //implicit Expansion
                var index = q3.IndexOf('[');
                var size = index < 0 ? q3 : q3.Remove(index);
                var count = cReg[size];
                for (int i = 0; i < count; i++)
                {
                    var name = string.Format("{0}[{1}]", size, i);
                    if (!conventionalMeasured.Contains(name)) { conventionalMeasured.Add(name); }
                }
            }
        }

        private static void ParseThreeGate(IEnumerator<string> token, string gate, Dictionary<string,int> qReg , StringBuilder builder)
        {
            token.MoveNext();
            var q1 = token.Current;
            token.MoveNext(); // ,
            token.MoveNext();
            var q2 = token.Current;
            token.MoveNext(); // ,
            token.MoveNext();
            var q3 = token.Current;
            token.MoveNext(); // 
            builder.Append(INDENTED);
            var loopRequired = qReg.Count != 0 && !((q1.Contains('[') && q2.Contains('[')  && q3.Contains('[')));
            if (loopRequired)
            {
                builder.Append(INDENTED);
                var index = q1.IndexOf('[');
                var size = index < 0 ? q3 : q1.Remove(index);
                builder.AppendFormat("for(_idx in 0..Length({0})){{\n", size);
                builder.Append("    ");
            }
            builder.AppendFormat("{0}({1},{2},{3});\n", gate,
                !loopRequired || q1.Contains('[') ? q1 : string.Format("{0}[_idx]", q1),
                !loopRequired || q2.Contains('[') ? q2 : string.Format("{0}[_idx]", q2),
                !loopRequired || q3.Contains('[') ? q3 : string.Format("{0}[_idx]", q3));
            if (loopRequired)
            {
                builder.Append(INDENTED);
                builder.AppendLine("}");
            }
        }

        /// <summary>
        /// Only checking the header
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        private static void ParseOpenQasmHeader(IEnumerator<string> token)
        {
            token.MoveNext(); //2.0
            if (!token.Current.Equals("2.0"))
            {
                Console.Error.WriteLine($"Parser has been written for version 2.0. Found version {token.Current}. Results may be incorrect.");
            };
            token.MoveNext(); //;
        }

        /// <summary>
        /// Intrinsic gates of Q#
        /// </summary>
        private static HashSet<string> Intrinsic = new HashSet<string>()
        {
            "id",
            "h", "x", "y", "z", "s", "t",
            "sdg", "tdg",
            "cx", "ccx",
            "measure"
        };

        private static void ParseGateSpecification(IEnumerator<string> token, string path, StringBuilder outside)
        {
            token.MoveNext();
            var gateName = token.Current;
            if (Intrinsic.Contains(gateName))
            {
                while (token.MoveNext() && !token.Current.Equals(CLOSE_CURLYBRACKET)) { }
                return;
            }

            var doubles = new List<string>();
            var qbits = new List<string>();
            bool withinParentheses = false;
            while (token.MoveNext() && !token.Current.Equals(OPEN_CURLYBRACKET))
            {
                if (token.Current.Equals(COMMA))
                {
                    continue;
                }
                else if (token.Current.Equals(OPEN_PARANTHESES))
                {
                    withinParentheses = true;
                }
                else if (token.Current.Equals(CLOSE_PARANTHESES))
                {
                    withinParentheses = false;
                }
                else if (withinParentheses)
                {
                    doubles.Add(ParseCalulation(token, COMMA, CLOSE_PARANTHESES));
                    if (token.Current.Equals(CLOSE_PARANTHESES))
                    {
                        withinParentheses = false;
                    }
                }
                else
                {
                    qbits.Add(token.Current);
                }
            }
            var types = doubles.Select(d => string.Format("{0}:Double", d))
                  .Concat(qbits.Select(qbit => string.Format("{0}:Qubit", qbit)));
            var conventionalMeasured = new List<string>();
            var inside = new StringBuilder();
            var qRegs = new Dictionary<string, int>();
            var cRegs = new Dictionary<string, int>();
            ParseApplication(token, cRegs, qRegs, path, inside, outside, conventionalMeasured);
            WriteOperation(outside, cRegs, qRegs, gateName, types, conventionalMeasured, inside);
        }

        /// <summary>
        /// Returns the input string with the first character converted to uppercase, or mutates any nulls passed into string.Empty
        /// </summary>
        /// <param name="s">Current string to be converted</param>
        /// <returns>Same string with the first letter capatalized (or an empty string if not posible)</returns>
        private static string FirstLetterToUpperCase(string s)
        {
            if (string.IsNullOrEmpty(s))
            {
                return string.Empty;
            }

            char[] a = s.ToCharArray();
            a[0] = char.ToUpper(a[0]);
            return new string(a);
        }

        /// <summary>
        /// Write the Q# operation with all the details
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="cRegs">Conventional registers defined</param>
        /// <param name="qRegs">Quantum registers defined</param>
        /// <param name="path">Directory the qasm is located in (mostly for inlcude purposes)</param>
        /// <param name="inside">Stream to write within the current operation being parsed</param>
        /// <param name="outside">Stream to write outside the current operation being parsed (mostly for defining side operations)</param>
        /// <param name="conventionalMeasured">Currently measured conventional registers (mostly used for output)</param>
        /// <param name="operationName">The intended name of the operation</param>
        /// <param name="types">Parameters of this operation (mostly used for gates)</param>
        private static void WriteOperation(StringBuilder outside, Dictionary<string, int> cRegs, Dictionary<string, int> qRegs, string operationName, IEnumerable<string> types, List<string> conventionalMeasured, StringBuilder inside)
        {
            outside.AppendFormat(HEADER_OPERATION, FirstLetterToUpperCase(operationName), string.Join(COMMA, types), conventionalMeasured.Any() ? "Result[]" : string.Empty);

            if (cRegs.Any()) {
                foreach (var cRegister in cRegs)
                {
                    outside.Append(INDENTED);
                    outside.AppendFormat("mutable {0} = new Result[{1}];\n", cRegister.Key, cRegister.Value);
                }
            }

            if (qRegs.Any())
            {
                foreach (var qbitRegister in qRegs)
                {
                    outside.Append(INDENTED);
                    outside.AppendFormat("using({0} = Qubit[{1}]){{\n", qbitRegister.Key, qbitRegister.Value);
                }
            }
            outside.Append(inside.ToString());
            if (qRegs.Any())
            {
                foreach (var qbitRegister in qRegs)
                {
                    outside.Append(INDENTED);
                    outside.AppendFormat("ResetAll({0});\n", qbitRegister.Key);
                }
                foreach (var qbitRegister in qRegs)
                {
                    outside.Append(INDENTED);
                    outside.AppendLine(CLOSE_CURLYBRACKET);
                }
            }
            if (conventionalMeasured.Count > 0)
            {
                outside.Append(INDENTED);
                outside.AppendFormat("return [{0}];\n", string.Join(POINT_COMMA, conventionalMeasured));
            }
            outside.AppendLine(TAIL_OPERATION);
        }

        /// <summary>
        /// Parse an U Gate which is a three axis rotation
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="builder"></param>
        private static void ParseUGate(IEnumerator<string> token, StringBuilder builder)
        {
            token.MoveNext(); //(
            token.MoveNext();
            var x = ParseCalulation(token, COMMA, CLOSE_PARANTHESES);
            token.MoveNext();
            var y = ParseCalulation(token, COMMA, CLOSE_PARANTHESES);
            token.MoveNext();
            var z = ParseCalulation(token, COMMA, CLOSE_PARANTHESES);
            token.MoveNext();
            var q = token.Current;
            token.MoveNext(); // ;
            bool written = false;
            if (!x.Equals(ZERO))
            {
                written = true;
                builder.Append(INDENTED);
                builder.AppendFormat("Rx({0},{1});\n", x, q);
            }
            if (!y.Equals(ZERO))
            {
                written = true;
                builder.Append(INDENTED);
                builder.AppendFormat("Ry({0},{1});\n", y, q);
            }
            if (!z.Equals(ZERO))
            {
                written = true;
                builder.Append(INDENTED);
                builder.AppendFormat("Rz({0},{1});\n", z, q);
            }
            if (!written)
            {
                // 0,0,0 rotation is the idle
                // Could have left it out, but people seem to use this as a first test and are supprized when it gets optimized away.
                builder.Append(INDENTED);
                builder.AppendFormat("I({0});\n", q);
            }
        }

        /// <summary>
        /// Parse a value, which can be a calculation or formula
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="endmarker">Marker to denote what to stop on</param>
        /// <returns>The value or concatenated formula</returns>
        private static string ParseCalulation(IEnumerator<string> token, params string[] endmarker)
        {
            string result = null;
            while (!(endmarker.Any(marker => marker.Equals(token.Current))))
            {
                if (token.Current.Equals(PI))
                {
                    result += "PI()";
                }
                else if (token.Current.All(c => char.IsDigit(c)))
                {
                    result += token.Current + ".0";
                }
                else
                {
                    result += token.Current;
                }
                if (!token.MoveNext()) { break; }
            }
            return result;
        }

        /// <summary>
        /// Parses the include statement
        /// Its not really clear by the specification, but an include may be anywhere in line and inject gates within an operation.
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="cRegs">Conventional registers defined</param>
        /// <param name="qRegs">Quantum registers defined</param>
        /// <param name="path">Directory the qasm is located in (mostly for inlcude purposes)</param>
        /// <param name="inside">Stream to write within the current operation being parsed</param>
        /// <param name="outside">Stream to write outside the current operation being parsed (mostly for defining side operations)</param>
        /// <param name="conventionalMeasured">Currently measured conventional registers (mostly used for output)</param>
        private static void ParseInclude(IEnumerator<string> token, Dictionary<string, int> cRegs, Dictionary<string,int> qRegs, string path, StringBuilder inside, StringBuilder outside, List<string> conventionalMeasured)
        {
            if (token.MoveNext())
            {
                var fileName = Path.Combine(path, token.Current);
                if (File.Exists(fileName))
                {
                    using (var stream = File.OpenText(fileName))
                    {
                        ParseApplication(Tokenizer(stream).GetEnumerator(), cRegs, qRegs, path, inside, outside, conventionalMeasured);
                    }
                    if (!token.MoveNext())
                    {
                        throw new Exception($"Expected ';' after 'include <filename>'");
                    }
                }
                //Some people use qelib1.inc or other include of a template but don't actually have the file or use it
                //So if the file is not there, just give a warning in the output and continue
                else
                {
                    outside.AppendLine($"//Warning: {fileName} was not found. Trying without");
                }
            }
            else
            {
                throw new Exception($"Unexpected end after include");
            }
        }

        /// <summary>
        /// Tokeinzer to split the stream of the file up in individual tokens
        /// </summary>
        /// <param name="stream">Filestream</param>
        /// <returns>Tokens in the code file</returns>
        public static IEnumerable<string> Tokenizer(StreamReader stream)
        {
            var token = new StringBuilder();
            var buffer = new char[1];

            while (stream.ReadBlock(buffer, 0, 1) == 1)
            {
                if (buffer[0] == '/')
                {
                    if (stream.ReadBlock(buffer, 0, 1) == 1)
                    {
                        //comment block
                        if (buffer[0] == '/')
                        {
                            //ignore rest of line
                            while (stream.ReadBlock(buffer, 0, 1) == 1 && buffer[0] != '\n') ;
                        }
                        // part of formula
                        else
                        {
                            //flush current token
                            if (token.Length != 0)
                            {
                                yield return token.ToString();
                                token.Clear();
                            }
                            yield return FORWARD_SLASH;
                            //Handle the caracter after the slash
                            if (char.IsLetterOrDigit(buffer[0]) || buffer[0] == '_' || buffer[0] == '.' || buffer[0] == '[' || buffer[0] == ']')
                            {
                                token.Append(buffer[0]);
                            }
                            else
                            {
                                switch (buffer[0])
                                {
                                    case '(': yield return OPEN_PARANTHESES; break;
                                    case ')': yield return CLOSE_PARANTHESES; break;
                                    case '{': yield return OPEN_CURLYBRACKET; break;
                                    case '}': yield return CLOSE_CURLYBRACKET; break;
                                    case ',': yield return COMMA; break;
                                    case ';': yield return POINT_COMMA; break;
                                    case '+': yield return PLUS; break;
                                    case '-': yield return MINUS; break;
                                    case '*': yield return STAR; break;
                                    default:
                                        //ignore
                                        break;
                                }
                            }
                        }
                    }
                    else
                    {
                        throw new Exception("Unexpected end of file");
                    }
                }
                else if (char.IsLetterOrDigit(buffer[0]) || buffer[0] == '_' || buffer[0] == '.' || buffer[0] == '[' || buffer[0] == ']')
                {
                    token.Append(buffer[0]);
                }
                else
                {
                    if (token.Length != 0)
                    {
                        yield return token.ToString();
                        token.Clear();
                    }
                    switch (buffer[0])
                    {
                        case '(': yield return OPEN_PARANTHESES; break;
                        case ')': yield return CLOSE_PARANTHESES; break;
                        case '{': yield return OPEN_CURLYBRACKET; break;
                        case '}': yield return CLOSE_CURLYBRACKET; break;
                        case ',': yield return COMMA; break;
                        case ';': yield return POINT_COMMA; break;
                        case '+': yield return PLUS; break;
                        case '-': yield return MINUS; break;
                        case '*': yield return STAR; break;
                        default:
                            //ignore
                            break;
                    }
                }
            }
        }

        #region Tokens and other constant Strings
        private const string OPEN_PARANTHESES = "(";
        private const string FORWARD_SLASH = "/";
        private const string OPEN_CURLYBRACKET = "{";
        private const string CLOSE_PARANTHESES = ")";
        private const string CLOSE_CURLYBRACKET = "}";
        private const string COMMA = ",";
        private const string POINT_COMMA = ";";
        private const string PLUS = "+";
        private const string MINUS = "-";
        private const string STAR = "*";
        private const string PI = "pi";
        private const string ZERO = "0.0";
        private const string HEADER =
@"namespace {0} {{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;
";
        private const string HEADER_OPERATION =
@"
    operation {0}({1}):({2})
    {{
        body
        {{
";
        private const string TAIL_OPERATION =

@"        }
    }
";
        private const string TAIL =
@"}
";
        private const string INDENTED = "            ";
        #endregion
    }

}
