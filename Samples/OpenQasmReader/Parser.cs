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

        public static string ConvertQasmFile(string ns, string path)
        {
            using (var file = File.OpenText(path))
            {
                return Convert(Tokenizer(file),ns, Path.GetFileNameWithoutExtension(path), Path.GetDirectoryName(path));
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

            ParseApplication(tokens, path, result);
            var builder = result;
            var format = Macro[string.Empty].Item2;
            result = new StringBuilder(builder.Length + format.Length);
            result.AppendFormat(
                format,
                ns,
                name,
                string.Join(COMMA, Enumerable.Repeat("Result[]", cRegs.Count)),
                builder.ToString(),
                string.Join(COMMA, cRegs)
                );
            return result.ToString();
        }

        private static void ParseApplication(IEnumerable<string> tokens, string path, StringBuilder builder)
        {
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
                        ParseInclude(token, path, builder);
                        break;
                    case "gate":
                        token.MoveNext();
                        var gateName = token.Current;

                        //Already defined ?
                        if (Macro.ContainsKey(gateName))
                        {
                            while (token.Current != CLOSE_CURLYBRACKET && token.MoveNext()) { }
                        }
                        else
                        {
                            var param = new Stack<string>();
                            while (token.MoveNext() && !token.Current.Equals(OPEN_CURLYBRACKET))
                            {
                                param.Push(token.Current);
                            }
                            throw new NotImplementedException();
                        }
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
                        ParseApplication(Tokenizer(stream), path, builder);
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
