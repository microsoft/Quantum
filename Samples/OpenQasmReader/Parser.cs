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
    /// A quick and simple qasm parser which was hand roled to remain under MIT license
    /// </summary>
    public class Parser
    {
        #region Constant Strings
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
        private const string HEADER =
@"namespace {0} {{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
";
        private const string HEADER_OPERATION =
@"
    operation {0}({1}):({2})
    {{
        body
        {{
";
        private const string TAIL_OPERATION =
@"
            return ({0});
        }}
    }}
";
        private const string TAIL =
@"}}
";
        #endregion

        public static string ConvertQasmFile(string ns, string path)
        {
            using (var file = File.OpenText(path))
            {
                return Convert(Tokenizer(file), ns, Path.GetFileNameWithoutExtension(path), Path.GetDirectoryName(path));
            }
        }

        public static string Convert(IEnumerable<string> tokens, string ns, string name, string path)
        {
            var result = new StringBuilder();
            var cRegs = new List<string>();

            result.AppendFormat(HEADER, ns);
            var token = tokens.GetEnumerator();
            ParseApplication(token, path, result);
            result.AppendFormat(HEADER_OPERATION, name, string.Empty, string.Join(COMMA, Enumerable.Repeat("Result[]", cRegs.Count)));
            result.AppendFormat(TAIL_OPERATION, string.Join(COMMA, cRegs));
            return result.ToString();
        }

        private static void ParseApplication(IEnumerator<string> token, string path, StringBuilder builder)
        {

            while (token.MoveNext())
            {
                switch (token.Current)
                {
                    case "OPENQASM":
                        token.MoveNext(); //2.0
                        if (!token.Current.Equals("2.0"))
                        {
                            Console.Error.WriteLine($"Parser has been written for version 2.0. Found version {token.Current}. Results may be incorrect.");
                        };
                        token.MoveNext(); //;
                        break;
                    case "include":
                        ParseInclude(token, path, builder);
                        break;
                    case "gate":
                        token.MoveNext();
                        var gateName = token.Current;

                        var doubles = new List<string>();
                        var qbits = new List<string>();
                        bool withinParentheses = false;
                        while (token.MoveNext() && !token.Current.Equals(OPEN_CURLYBRACKET))
                        {
                            if (token.Current.Equals(OPEN_PARANTHESES))
                            {
                                withinParentheses = true;
                            }
                            else if (token.Current.Equals(CLOSE_PARANTHESES))
                            {
                                withinParentheses = false;
                            } 
                            else if (!(token.Current.Equals(COMMA)))
                            {
                                if (withinParentheses)
                                {
                                    doubles.Add(token.Current);
                                }
                                else
                                {
                                    qbits.Add(token.Current);
                                }
                            }
                        }
                        var types = doubles.Select(d => string.Format("Double {0}", d))
                              .Concat(qbits.Select(qbit => string.Format("Qubit {0}", qbit)));
                        builder.AppendFormat(HEADER_OPERATION, gateName, string.Join(COMMA, types), string.Empty);
                        ParseApplication(token, path, builder);
                        builder.AppendFormat(TAIL_OPERATION, string.Empty);
                        break;
                    case "U":
                        token.MoveNext(); //(
                        string x = null;
                        string y = null;
                        string z = null;
                        while (token.MoveNext() && !(token.Current.Equals(COMMA)))
                        {
                            if (token.Current.Equals(PI))
                            {
                                x += "Math.PI";
                            }
                            else
                            {
                                x += token.Current;
                            }
                        }
                        while (token.MoveNext() && !(token.Current.Equals(COMMA)))
                        {
                            if (token.Current.Equals(PI))
                            {
                                y += "Math.PI";
                            }
                            else
                            {
                                y += token.Current;
                            }
                        }
                        while (token.MoveNext() && !(token.Current.Equals(CLOSE_PARANTHESES)))
                        {
                            if (token.Current.Equals(PI))
                            {
                                z += "Math.PI";
                            }
                            else
                            {
                                z += token.Current;
                            }
                        }
                        token.MoveNext();
                        var q = token.Current;
                        token.MoveNext(); // ;
                        builder.AppendFormat("Rx({0}) {1};", x, q);
                        builder.AppendFormat("Ry({0}) {1};", y, q);
                        builder.AppendFormat("Rz({0}) {1};", z, q);
                        break;
                    case "CX":
                    case "cx":
                        token.MoveNext();
                        var q1 = token.Current;
                        token.MoveNext();
                        var q2 = token.Current;
                        token.MoveNext(); // ;
                        builder.AppendFormat("CX {0} {1};", q1, q2);
                        break;
                    case CLOSE_CURLYBRACKET:
                        return;
                    case POINT_COMMA:
                        break;
                    default:
                        throw new Exception($"Unexpected token:{token.Current}");
                }
            }
        }
        
        private static void ParseInclude(IEnumerator<string> token, string path, StringBuilder builder)
        {
            if (token.MoveNext())
            {
                var fileName = Path.Combine(path, token.Current);
                if (File.Exists(fileName))
                {
                    using (var stream = File.OpenText(fileName))
                    {
                        ParseApplication(Tokenizer(stream).GetEnumerator(), path, builder);
                    }
                    if (!token.MoveNext())
                    {
                        throw new Exception($"Expected ';' after 'include <filename>'");
                    }
                }
                else
                {
                    throw new Exception($"Missing Include: {fileName}");
                }
            }
            else
            {
                throw new Exception($"Unexpected end after include");
            }
        }

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
                            yield return FORWARD_SLASH;
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
    }

}
