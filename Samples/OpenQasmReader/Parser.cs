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
        public static string ParseQasmFile(string ns, string path)
        {
            using (var file = File.OpenText(path))
            {
                return Convert(Tokenizer(file),ns, Path.GetFileNameWithoutExtension(path), path);
            }
        }

        private static Dictionary<string, Tuple<int, string>> Macro { get; } = new Dictionary<string, Tuple<int, string>>()
        {
            {
                string.Empty, new Tuple<int, string>(4,
@"namespace {0} {{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    operation {1}():({2})
    {{
        body
        {{
{3}
          return ({4});
        }}
    }}
}}")         }
        };

        public static string Convert(IEnumerable<string> tokens, string ns, string name, string path)
        {
            var result = new StringBuilder();
            var cRegs = new List<string>();

            var token = tokens.GetEnumerator();
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
                        ParseMarcro(token);
                        break;
                    case "gate":
                        token.MoveNext();
                        var gateName = token.Current;
                        if (Intrinsic.Contains(gateName))
                        {
                            while (token.Current != "}" && token.MoveNext()) { }
                        }
                        else
                        {
                            var param = new Stack<string>();
                            while (token.MoveNext() && !token.Current.Equals("{"))
                            {
                                param.Push(token.Current);
                            }
                        }
                        break;
                    default:
                        throw new Exception($"Unexpected token:{token.Current}");
                }
            }
            var builder = result;
            var format = Macro[string.Empty].Item2;
            result = new StringBuilder(builder.Length + format.Length);
            result.AppendFormat(
                format,
                ns,
                name,
                string.Join(",", Enumerable.Repeat("Result[]", cRegs.Count)),
                builder.ToString(),
                string.Join(",", cRegs)
                );
            return result.ToString();
        }

        private static void ParseMarcro(IEnumerator<string> token)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Gates which are intrinsic to Q#, so don't need redefintions
        /// </summary>
        private static readonly HashSet<string> Intrinsic = new HashSet<string>()
        {
            "u1", "u3",
            "cx", "ccx",
            "h", "t", "s", "id",
            "x", "y", "z",
            "xz", "xy", "xz",
            "rx", "ry", "rz"
        };

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
                            yield return "/";
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
                        case '(': yield return "("; break;
                        case ')': yield return ")"; break;
                        case ',': yield return ","; break;
                        case ';': yield return ";"; break;
                        case '+': yield return "+"; break;
                        case '-': yield return "-"; break;
                        case '*': yield return "*"; break;
                        default:
                            //ignore
                            break;
                    }
                }
            }
        }
    }

}
