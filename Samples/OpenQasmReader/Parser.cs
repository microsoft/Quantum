// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;

//Export internal functions to able to test this class
[assembly: InternalsVisibleTo("OpenQasmReader.Tests")]

namespace Microsoft.Quantum.Samples.OpenQasmReader
{
    /// <summary>
    /// A quick and simple qasm parser and Q# generator which was hand rolled to remain under MIT license
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

        internal static string ConvertQasmFile(string ns, string path)
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
        private static string ParseMain(IEnumerator<string> token, string ns, string name, string path)
        {
            var classicalMeasured = new List<string>();
            var qubitMeasured = new List<string>();
            var qRegs = new Dictionary<string, int>();
            var cRegs = new Dictionary<string, int>();
            var inside = new StringBuilder();
            var outside = new StringBuilder();
            IndentLevel += 4;
            ParseApplication(token, cRegs, qRegs, path, inside, outside, classicalMeasured, qubitMeasured);

            var result = new StringBuilder(inside.Length + outside.Length);
            result.AppendFormat(HEADER, ns);
            result.Append(outside.ToString());
            WriteOperation(result, cRegs, qRegs, name, new string[] { }, classicalMeasured, qubitMeasured, inside);
            IndentLevel -= 4;
            result.Append(TAIL);
            return result.ToString();
        }

        /// <summary>
        /// Parses the Qasm application and components
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="cRegs">Classical registers defined</param>
        /// <param name="qRegs">Quantum registers defined</param>
        /// <param name="path">Directory the qasm is located in (mostly for include purposes)</param>
        /// <param name="inside">Stream to write within the current operation being parsed</param>
        /// <param name="outside">Stream to write outside the current operation being parsed (mostly for defining side operations)</param>
        /// <param name="classicalMeasured">Currently measured classical registers (mostly used for output)</param>
        /// <param name="qubitMeasured">Currently solo measured qubit (used for output)</param>
        /// <param name="stopAfterOneCommand">Process only one command</param>
        internal static void ParseApplication(IEnumerator<string> token, Dictionary<string, int> cRegs, Dictionary<string, int> qRegs, string path, StringBuilder inside, StringBuilder outside, List<string> classicalMeasured, List<string> qubitMeasured, bool stopAfterOneCommand = false)
        {
            while (token.MoveNext())
            {
                switch (token.Current)
                {
                    case "OPENQASM":
                        ParseOpenQasmHeader(token);
                        break;
                    case "include":
                        ParseInclude(token, cRegs, qRegs, path, inside, outside, classicalMeasured, qubitMeasured);
                        break;
                    //Intrinsic will take care of the optional native gates
                    case "opaque":
                    case "gate":
                        ParseGateSpecification(token, path, outside);
                        break;
                    case "qreg":
                        ParseQuantumRegister(token, qRegs);
                        break;
                    case "creg":
                        ParseClassicalRegister(token, cRegs, inside);
                        break;
                    case "U":
                    case "u3":
                        ParseUGate(token, inside);
                        break;
                    case "u1":
                        ParseU1Gate(token, inside);
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
                    case "barrier":
                        ParseBarrier(token, qRegs);
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
                        ParseMeasure(token, inside, cRegs, qRegs, classicalMeasured, qubitMeasured);
                        break;
                    case "if":
                        ParseIf(token, cRegs, qRegs, path, inside, outside, classicalMeasured, qubitMeasured);
                        break;
                    case CLOSE_CURLYBRACKET:
                        return;
                    case POINT_COMMA:
                        if (stopAfterOneCommand) { return; }
                        break;
                    default:
                        ParseGateCall(token, inside, qRegs);
                        break;
                }
                if (stopAfterOneCommand && token.Current.Equals(POINT_COMMA)) { return; }
            }
        }

        /// <summary>
        /// Parse the if conditional
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="cRegs">Classical registers defined</param>
        /// <param name="qRegs">Quantum registers defined</param>
        /// <param name="path">Directory the qasm is located in (mostly for include purposes)</param>
        /// <param name="inside">Stream to write within the current operation being parsed</param>
        /// <param name="outside">Stream to write outside the current operation being parsed (mostly for defining side operations)</param>
        /// <param name="classicalMeasured">Currently measured classical registers (mostly used for output)</param>
        /// <param name="qubitMeasured">Currently solo measured qubit (used for output)</param>
        /// <param name="stopOnePointcomma">Process one command</param>
        private static void ParseIf(IEnumerator<string> token, Dictionary<string, int> cRegs, Dictionary<string, int> qRegs, string path, StringBuilder inside, StringBuilder outside, List<string> classicalMeasured, List<string> qubitMeasured)
        {
            token.MoveNext();
            token.MoveNext();
            var condition = ParseCondition(token, cRegs, CLOSE_PARENTHESES);
            Indent(inside);
            inside.AppendFormat("if({0}){{\n", condition);
            IndentLevel++;
            ParseApplication(token, cRegs, qRegs, path, inside, outside, classicalMeasured, qubitMeasured, true);
            IndentLevel--;
            Indent(inside);
            inside.AppendLine("}");
        }

        /// <summary>
        /// Add indentation
        /// </summary>
        /// <param name="stream">Current Stream</param>
        private static void Indent(StringBuilder stream)
        {
            var indent = IndentLevel * INDENT;
            while (indent-- > 0)
            {
                stream.Append(' ');
            }
        }
        private static int IndentLevel { get; set; }

        /// <summary>
        /// Parses a condition statement
        /// </summary>
        /// <param name="token">current token</param>
        /// <param name="cRegs">traditional register</param>
        /// <param name="endmarker">current marker of an end</param>
        /// <returns>The total condition statement</returns>
        internal static string ParseCondition(IEnumerator<string> token, Dictionary<string, int> cRegs, params string[] endmarker)
        {
            int depth = 0;
            string result = null;
            while (depth != 0 || !(endmarker.Any(marker => marker.Equals(token.Current))))
            {
                if (token.Current.Equals(OPEN_PARENTHESES))
                {
                    depth++;
                    result += token.Current;
                }
                else if (token.Current.Equals(CLOSE_PARENTHESES))
                {
                    depth--;
                    result += token.Current;
                }
                else if (cRegs.ContainsKey(token.Current))
                {
                    result += string.Format("ResultAsInt({0})", token.Current);
                }
                else if (token.Current.Equals(PI))
                {
                    result += "PI()";
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
        /// Register a classical (Result) register
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="cRegs">Classical registers defined</param>
        /// <param name="path">Directory the qasm is located in (mostly for include purposes)</param>
        private static void ParseClassicalRegister(IEnumerator<string> token, Dictionary<string, int> cRegs, StringBuilder inside)
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
            var index = name.IndexOf('[') + 1;
            var count = int.Parse(name.Substring(index, name.IndexOf(']') - index));
            qRegs.Add(name.Remove(index - 1), count);
            token.MoveNext(); //;
        }

        private static void ParseGateCall(IEnumerator<string> token, StringBuilder builder, Dictionary<string, int> qReg)
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
                else if (token.Current.Equals(CLOSE_PARENTHESES))
                {
                    withinParentheses = false;
                }
                else if (withinParentheses)
                {
                    doubles.Add(ParseCalculation(token, COMMA, CLOSE_PARENTHESES));
                    if (token.Current.Equals(CLOSE_PARENTHESES))
                    {
                        withinParentheses = false;
                    }
                }
                else if (token.Current.Equals(OPEN_PARENTHESES))
                {
                    withinParentheses = true;
                }
                else
                {
                    qbits.Add(token.Current);
                }
            }

            var loopRequired = qReg.Count != 0 && qbits.Any() && !qbits.Any(q => q.Contains('['));
            if (loopRequired)
            {
                Indent(builder);
                var size = qbits.First(q => !q.Contains('['));
                builder.AppendFormat("for(_idx in 0..Length({0})){{\n", size);
                IndentLevel++;
            }
            Indent(builder);
            builder.Append(FirstLetterToUpperCase(gateName));
            builder.Append('(');
            var types = doubles.Concat(qbits.Select(qbit => IndexedCall(qbit, qbit.Contains('['))));
            builder.Append(string.Join(COMMA, types));
            builder.AppendLine(");");
            if (loopRequired)
            {
                IndentLevel--;
                Indent(builder);
                builder.AppendLine("}");
            }
        }

        internal static void ParseBarrier(IEnumerator<string> token, Dictionary<string, int> qReg)
        {
            //Ignore, because its by default in Q#
            while (token.MoveNext() && !token.Current.Equals(POINT_COMMA)) { }
        }

        private static void ParseOneGate(IEnumerator<string> token, string gate, Dictionary<string, int> qReg, StringBuilder builder)
        {
            token.MoveNext();
            var q1 = token.Current;
            token.MoveNext(); // ;
            Indent(builder);
            if (qReg.Count == 0 || q1.Contains('['))
            {
                builder.AppendFormat("{0}({1});\n", gate, q1);
            }
            //Implicit expansion
            else
            {
                builder.AppendFormat("ApplyToEach({0},{1});\n", gate, q1);
            }
        }

        private static void ParseTwoGate(IEnumerator<string> token, string gate, Dictionary<string, int> qReg, StringBuilder builder)
        {
            token.MoveNext();
            var leftQubit = token.Current;
            token.MoveNext(); // ,
            token.MoveNext();
            var rightQubit = token.Current;
            token.MoveNext(); // ;
            Indent(builder);
            if (qReg.Count == 0 || (leftQubit.Contains('[') && rightQubit.Contains('[')))
            {
                builder.AppendFormat("{0}({1},{2});\n", gate, leftQubit, rightQubit);
            }
            else
            {
                var index = leftQubit.IndexOf('[');
                var size = index < 0 ? leftQubit : leftQubit.Remove(index);
                builder.AppendFormat("for(_idx in 0..Length({0})){{\n", size);
                IndentLevel++;
                Indent(builder);
                builder.AppendFormat("{0}({1},{2});\n", gate,
                    IndexedCall(leftQubit, true),
                    IndexedCall(rightQubit, true));
                IndentLevel--;
                Indent(builder);
                builder.AppendLine("}");
            }
        }

        /// <summary>
        /// Parse a measure gate
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="cRegs">Classical registers defined</param>
        /// <param name="builder">Stream to write within the current operation being parsed</param>
        /// <param name="qRegs">Quantum registers defined</param>
        /// <param name="classicalMeasured">Currently measured classical registers (mostly used for output)</param>
        /// <param name="qubitMeasured">Currently solo measured qubit (used for output)</param>
        private static void ParseMeasure(IEnumerator<string> token, StringBuilder builder, Dictionary<string, int> cReg, Dictionary<string, int> qReg, List<string> classicalMeasured, List<string> qubitMeasured)
        {
            token.MoveNext();
            var q1 = token.Current;
            token.MoveNext(); // -
            if (POINT_COMMA.Equals(token.Current)) //Implicit measure
            {
                var loopRequired = qReg.Count != 0 && !q1.Contains('[');
                if (loopRequired) //implicit Expansion
                {
                    Indent(builder);
                    var size = qReg[q1];
                    for (int i = 0; i < size; i++)
                    {
                        Indent(builder);
                        builder.AppendFormat("set _out[{0}] = M({1}[{2}]);\n", i, q1, i);
                        qubitMeasured.Add(q1 + $"[{i}]");
                    }
                }
                else
                {
                    Indent(builder);
                    builder.AppendFormat("set _out[{0}] = M({1});\n", qubitMeasured.Count, q1);
                    qubitMeasured.Add(q1);
                }
            }
            else //Explicit measure
            {
                token.MoveNext(); // >
                token.MoveNext();
                var q3 = token.Current;
                token.MoveNext(); // 

                var loopRequired = qReg.Count != 0 && !(q1.Contains('[') && q3.Contains('['));
                if (loopRequired)
                {
                    Indent(builder);
                    var index = q1.IndexOf('[');
                    var size = index < 0 ? q3 : q1.Remove(index);
                    builder.AppendFormat("for(_idx in 0..Length({0})){{\n", size);
                    IndentLevel++;
                }
                Indent(builder);
                builder.AppendFormat("set {0} = M({1});\n", IndexedCall(q3, loopRequired), IndexedCall(q1, loopRequired));
                if (loopRequired)
                {
                    IndentLevel--;
                    Indent(builder);
                    builder.AppendLine("}");
                }

                if (q3.Contains('['))
                {
                    if (!classicalMeasured.Contains(q3)) { classicalMeasured.Add(q3); }
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
                        if (!classicalMeasured.Contains(name)) { classicalMeasured.Add(name); }
                    }
                }
            }
        }

        /// <summary>
        /// Parse a gate with three Qbits (e.g. CCNOT)
        /// </summary>
        /// <param name="gate">Gate being parsed</param>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="builder">Stream to write within the current operation being parsed</param>
        /// <param name="qRegs">Quantum registers defined</param>
        private static void ParseThreeGate(IEnumerator<string> token, string gate, Dictionary<string, int> qReg, StringBuilder builder)
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
            Indent(builder);
            var loopRequired = qReg.Count != 0 && !((q1.Contains('[') && q2.Contains('[') && q3.Contains('[')));
            if (loopRequired)
            {
                Indent(builder);
                var index = q1.IndexOf('[');
                var size = index < 0 ? q3 : q1.Remove(index);
                builder.AppendFormat("for(_idx in 0..Length({0})){{\n", size);
                IndentLevel++;
            }
            Indent(builder);
            builder.AppendFormat("{0}({1},{2},{3});\n", gate,
                IndexedCall(q1, loopRequired),
                IndexedCall(q2, loopRequired),
                IndexedCall(q3, loopRequired));
            if (loopRequired)
            {
                IndentLevel--;
                Indent(builder);
                builder.AppendLine("}");
            }
        }

        /// <summary>
        /// Makes a reference to a register an indexed reference if we need a loop
        /// OpenQasm has implicit loops, which Q# needs to be explicit
        /// </summary>
        /// <param name="name">Register name</param>
        /// <param name="loopRequired"></param>
        /// <returns></returns>
        internal static string IndexedCall(string name, bool loopRequired)
        {
            return !loopRequired || name.Contains('[') ? name : string.Format("{0}[_idx]", name);
        }

        /// <summary>
        /// Only checking the header
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        internal static void ParseOpenQasmHeader(IEnumerator<string> token)
        {
            token.MoveNext(); //2.0
            if (!token.Current.Equals("2.0"))
            {
                Console.Error.WriteLine($"//Parser has been written for version 2.0. Found version {token.Current}. Results may be incorrect.");
            };
            token.MoveNext(); //;
        }

        /// <summary>
        /// Intrinsic gates of Q#
        /// </summary>
        private readonly static HashSet<string> Intrinsic = new HashSet<string>()
        {
            "id", "barrier",
            "h", "x", "y", "z", "s", "t",
            "sdg", "tdg",
            "cx", "ccx",
            "measure",
            "u1","u3"
        };

        /// <summary>
        /// Parses a gate (and opaque gate) definition
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="path">Directory the qasm is located in (mostly for include purposes)</param>
        /// <param name="outside">Stream to write outside the current operation being parsed (mostly for defining side operations)</param>
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
                else if (token.Current.Equals(CLOSE_PARENTHESES))
                {
                    withinParentheses = false;
                }
                else if (withinParentheses)
                {
                    doubles.Add(ParseCalculation(token, COMMA, CLOSE_PARENTHESES));
                    if (token.Current.Equals(CLOSE_PARENTHESES))
                    {
                        withinParentheses = false;
                    }
                }
                else if (token.Current.Equals(OPEN_PARENTHESES))
                {
                    withinParentheses = true;
                }
                else
                {
                    qbits.Add(token.Current);
                }
            }
            var types = doubles.Select(d => string.Format("{0}:Double", d))
                  .Concat(qbits.Select(qbit => string.Format("{0}:Qubit", qbit)));
            var classicalMeasured = new List<string>();
            var qubitMeasured = new List<string>();
            var inside = new StringBuilder();
            var qRegs = new Dictionary<string, int>();
            var cRegs = new Dictionary<string, int>();
            ParseApplication(token, cRegs, qRegs, path, inside, outside, classicalMeasured, qubitMeasured);
            WriteOperation(outside, cRegs, qRegs, gateName, types, classicalMeasured, qubitMeasured, inside);
        }

        /// <summary>
        /// Returns the input string with the first character converted to uppercase, or mutates any nulls passed into string.Empty
        /// </summary>
        /// <param name="s">Current string to be converted</param>
        /// <returns>Same string with the first letter capitalized (or an empty string if not possible)</returns>
        internal static string FirstLetterToUpperCase(string s)
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
        /// <param name="cRegs">Classical registers defined</param>
        /// <param name="qRegs">Quantum registers defined</param>
        /// <param name="path">Directory the qasm is located in (mostly for include purposes)</param>
        /// <param name="inside">Stream to write within the current operation being parsed</param>
        /// <param name="outside">Stream to write outside the current operation being parsed (mostly for defining side operations)</param>
        /// <param name="classicalMeasured">Currently measured classical registers (mostly used for output)</param>
        /// <param name="qubitMeasured">Currently solo measured qubit (used for output)</param>
        /// <param name="operationName">The intended name of the operation</param>
        /// <param name="types">Parameters of this operation (mostly used for gates)</param>
        private static void WriteOperation(StringBuilder outside, Dictionary<string, int> cRegs, Dictionary<string, int> qRegs, string operationName, IEnumerable<string> types, List<string> classicalMeasured, List<string> qubitMeasured, StringBuilder inside)
        {
            outside.AppendFormat(HEADER_OPERATION, FirstLetterToUpperCase(operationName), string.Join(COMMA, types), classicalMeasured.Any() || qubitMeasured.Any() ? "Result[]" : string.Empty);

            if (qRegs.Any())
            {
                //Move indentation a bit back
                IndentLevel--;
            }

            if (qubitMeasured.Any())
            {
                Indent(outside);
                outside.AppendLine($"mutable _out = new Result[{qubitMeasured.Count}];");
            }
            if (cRegs.Any())
            {
                foreach (var cRegister in cRegs)
                {
                    Indent(outside);
                    outside.AppendFormat("mutable {0} = new Result[{1}];\n", cRegister.Key, cRegister.Value);
                }
            }

            if (qRegs.Any())
            {
                foreach (var qbitRegister in qRegs)
                {
                    Indent(outside);
                    outside.AppendFormat("using({0} = Qubit[{1}]){{\n", qbitRegister.Key, qbitRegister.Value);
                }
            }
            outside.Append(inside.ToString());
            if (qRegs.Any())
            {
                IndentLevel++;
                foreach (var qbitRegister in qRegs)
                {
                    Indent(outside);
                    outside.AppendFormat("ResetAll({0});\n", qbitRegister.Key);
                }
                IndentLevel--;
                foreach (var qbitRegister in qRegs)
                {
                    Indent(outside);
                    outside.AppendLine(CLOSE_CURLYBRACKET);
                }
            }
            if (classicalMeasured.Any() || qubitMeasured.Any())
            {
                Indent(outside);
                var result = Enumerable.Range(0, qubitMeasured.Count).Select(n => $"_out[{n}]")
                    .Concat(classicalMeasured);
                outside.AppendFormat("return [{0}];\n", string.Join(POINT_COMMA, result));
            }
            if (qRegs.Any())
            {
                IndentLevel++;
            }
            outside.AppendLine(TAIL_OPERATION);
        }

        /// <summary>
        /// Parse an U1 Gate which is a one axis rotation
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="builder"></param>
        private static void ParseU1Gate(IEnumerator<string> token, StringBuilder builder)
        {
            token.MoveNext(); //(
            token.MoveNext();
            var x = ParseCalculation(token, COMMA, CLOSE_PARENTHESES);
            token.MoveNext();
            var q = token.Current;
            token.MoveNext(); // ;
            if (!x.Equals(ZERO))
            {
                Indent(builder);
                builder.AppendFormat("Rx({0},{1});\n", x, q);
            }
            else
            {
                // 0,0,0 rotation is the idle
                // Could have left it out, but people seem to use this as a first test and are surprised when it gets optimized away.
                Indent(builder);
                builder.AppendFormat("I({0});\n", q);
            }
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
            var x = ParseCalculation(token, COMMA, CLOSE_PARENTHESES);
            token.MoveNext();
            var y = ParseCalculation(token, COMMA, CLOSE_PARENTHESES);
            token.MoveNext();
            var z = ParseCalculation(token, COMMA, CLOSE_PARENTHESES);
            token.MoveNext();
            var q = token.Current;
            token.MoveNext(); // ;
            bool written = false;
            if (!x.Equals(ZERO))
            {
                written = true;
                Indent(builder);
                builder.AppendFormat("Rx({0},{1});\n", x, q);
            }
            if (!y.Equals(ZERO))
            {
                written = true;
                Indent(builder);
                builder.AppendFormat("Ry({0},{1});\n", y, q);
            }
            if (!z.Equals(ZERO))
            {
                written = true;
                Indent(builder);
                builder.AppendFormat("Rz({0},{1});\n", z, q);
            }
            if (!written)
            {
                // 0,0,0 rotation is the idle
                // Could have left it out, but people seem to use this as a first test and are surprised when it gets optimized away.
                Indent(builder);
                builder.AppendFormat("I({0});\n", q);
            }
        }

        /// <summary>
        /// Parse a value, which can be a calculation or formula
        /// </summary>
        /// <param name="token">Current token the tokenizer is on to parse</param>
        /// <param name="endmarker">Marker to denote what to stop on</param>
        /// <returns>The value or concatenated formula</returns>
        internal static string ParseCalculation(IEnumerator<string> token, params string[] endmarker)
        {
            int depth = 0;
            string result = null;
            while (depth != 0 || !(endmarker.Any(marker => marker.Equals(token.Current))))
            {
                if (token.Current.Equals(OPEN_PARENTHESES))
                {
                    depth++;
                    result += token.Current;
                }
                else if (token.Current.Equals(CLOSE_PARENTHESES))
                {
                    depth--;
                    result += token.Current;
                }
                else if (token.Current.Equals(PI))
                {
                    result += "PI()";
                }
                else if (token.Current.All(c => char.IsDigit(c)))
                {
                    result += token.Current + ".0";
                }
                //Scientific value
                else if (char.IsDigit(token.Current[0]) && token.Current.Last() == 'e')
                {
                    result += token.Current;
                    token.MoveNext();
                    result += token.Current;
                    token.MoveNext();
                    result += token.Current;
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
        /// <param name="cRegs">Classical registers defined</param>
        /// <param name="qRegs">Quantum registers defined</param>
        /// <param name="path">Directory the qasm is located in (mostly for include purposes)</param>
        /// <param name="inside">Stream to write within the current operation being parsed</param>
        /// <param name="outside">Stream to write outside the current operation being parsed (mostly for defining side operations)</param>
        /// <param name="classicalMeasured">Currently measured classical registers (mostly used for output)</param>
        /// <param name="qubitMeasured">Currently solo measured qubit (used for output)</param>
        internal static void ParseInclude(IEnumerator<string> token, Dictionary<string, int> cRegs, Dictionary<string, int> qRegs, string path, StringBuilder inside, StringBuilder outside, List<string> classicalMeasured, List<string> qubitMeasured)
        {
            if (token.MoveNext())
            {
                var fileName = token.Current;
                while (token.MoveNext() && !token.Current.Equals(POINT_COMMA))
                {
                    fileName += token.Current;
                }

                fileName = Path.Combine(path, fileName);
                if (File.Exists(fileName))
                {
                    using (var stream = File.OpenText(fileName))
                    {
                        ParseApplication(Tokenizer(stream).GetEnumerator(), cRegs, qRegs, path, inside, outside, classicalMeasured, qubitMeasured);
                    }
                }
                //Some people use qelib1.inc or other include of a template but don't actually have the file or use it
                //So if the file is not there, just give a warning in the output and continue
                else
                {
                    outside.AppendLine($"//Generated without includes of {fileName} because the file was not found during generation.");
                }
            }
            else
            {
                throw new Exception($"Unexpected end after include");
            }
        }

        /// <summary>
        /// Tokenizer to split the stream of the file up in individual tokens
        /// </summary>
        /// <param name="stream">Filestream</param>
        /// <returns>Tokens in the code file</returns>
        internal static IEnumerable<string> Tokenizer(TextReader stream)
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
                            //Handle the character after the slash
                            if (char.IsLetterOrDigit(buffer[0]) || buffer[0] == '_' || buffer[0] == '.' || buffer[0] == '[' || buffer[0] == ']')
                            {
                                token.Append(buffer[0]);
                            }
                            else
                            {
                                switch (buffer[0])
                                {
                                    case '(': yield return OPEN_PARENTHESES; break;
                                    case ')': yield return CLOSE_PARENTHESES; break;
                                    case '{': yield return OPEN_CURLYBRACKET; break;
                                    case '}': yield return CLOSE_CURLYBRACKET; break;
                                    case ',': yield return COMMA; break;
                                    case ';': yield return POINT_COMMA; break;
                                    case '+': yield return PLUS; break;
                                    case '-': yield return MINUS; break;
                                    case '*': yield return STAR; break;
                                    case '=': yield return IS; break;
                                    case '!': yield return NOT; break;
                                    case '<': yield return LT; break;
                                    case '>': yield return MT; break;
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
                        case '(': yield return OPEN_PARENTHESES; break;
                        case ')': yield return CLOSE_PARENTHESES; break;
                        case '{': yield return OPEN_CURLYBRACKET; break;
                        case '}': yield return CLOSE_CURLYBRACKET; break;
                        case ',': yield return COMMA; break;
                        case ';': yield return POINT_COMMA; break;
                        case '+': yield return PLUS; break;
                        case '-': yield return MINUS; break;
                        case '*': yield return STAR; break;
                        case '=': yield return IS; break;
                        case '!': yield return NOT; break;
                        case '<': yield return LT; break;
                        case '>': yield return MT; break;
                        default:
                            //ignore
                            break;
                    }
                }
            }
            if (token.Length != 0)
            {
                yield return token.ToString();
            }
        }

        #region Tokens and other constant Strings
        private const string OPEN_PARENTHESES = "(";
        private const string FORWARD_SLASH = "/";
        private const string OPEN_CURLYBRACKET = "{";
        private const string CLOSE_PARENTHESES = ")";
        private const string CLOSE_CURLYBRACKET = "}";
        private const string COMMA = ",";
        private const string POINT_COMMA = ";";
        private const string PLUS = "+";
        private const string MINUS = "-";
        private const string STAR = "*";
        private const string IS = "=";
        private const string NOT = "!";
        private const string LT = "<";
        private const string MT = ">";
        private const string PI = "pi";
        private const string ZERO = "0.0";
        private const string HEADER =
@"namespace {0}
{{
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
    }";
        private const string TAIL = @"}";
        //Four spaces
        internal const int INDENT = 4;
        #endregion
    }

}
