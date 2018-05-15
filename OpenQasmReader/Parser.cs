// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace OpenQasmReader
{
    /// <summary>
    /// A quick and simple qasm parser which was hand roled to remain under MIT license
    /// </summary>
    public class Parser
    {
        public static Method Parse(string path)
        {
            using (var file = File.OpenText(path))
            {
                return ParseHeader(file, Path.GetFileNameWithoutExtension(path));
            }
        }

        /// <summary>
        /// Parses the header
        /// SPEC: mainprogram: "OPENQASM" real ";" program
        /// </summary>
        /// <param name="stream">stream</param>
        /// <returns></returns>
        private static Method ParseHeader(StreamReader stream, string operationName)
        {
            var buffer = new char[64];
            int line = 1;
            int column = 0;


            while (true)
            {
                if (stream.ReadBlock(buffer, 0, 1) == 0)
                {
                    throw new InvalidOperationException($"Unexpected EOF on line {line}");
                }
                var letter = buffer[0];
                if (letter == '\r') { continue; } //Ignore for windows
                column++;

                #region Ignore Whitespace
                if (char.IsWhiteSpace(letter))
                {
                    if ('\n' == letter)
                    {
                        column = 0;
                        line++;
                    }
                    continue;
                }
                #endregion
                switch (letter)
                {
                    case '/':
                        #region Ignore comment
                        if (stream.ReadBlock(buffer, 0, 1) == 1 && buffer[0] == '/')
                        {
                            MoveNextLine(buffer, ref line, ref column, stream);
                            continue;
                        }
                        else
                        {
                            throw new InvalidOperationException($"Expecting '//' line:{line} column: {column}");
                        }
                        #endregion
                    case 'O':
                    case 'o':
                        if (stream.ReadBlock(buffer, 0, 7) == 7 &&
                            char.ToUpper(buffer[0]) == 'P' &&
                            char.ToUpper(buffer[1]) == 'E' &&
                            char.ToUpper(buffer[2]) == 'N' &&
                            char.ToUpper(buffer[3]) == 'Q' &&
                            char.ToUpper(buffer[4]) == 'A' &&
                            char.ToUpper(buffer[5]) == 'S' &&
                            char.ToUpper(buffer[6]) == 'M')
                        {
                            column += 7;
                            MoveWhiteSpace(buffer, ref column, stream);
                            CheckNotEndStream(line, column, stream);
                            CheckVersionNumber(buffer, line, ref column, stream);
                            MoveWhiteSpace(buffer, ref column, stream);
                            if (buffer[0] != ';')
                            {
                                throw new InvalidOperationException($"Expected ';' at line:{line} column: {column}");
                            }
                            return ParseApplication(buffer, line, column, stream, operationName);
                        }
                        throw new InvalidOperationException($"Expected OPENQASM on line:{line} column: {column}");
                    default:
                        throw new InvalidOperationException($"Expected OPENQASM on line:{line} column: {column}");
                }
            }
        }

        /// <summary>
        /// Read untill no whitespace
        /// </summary>
        /// <param name="buffer"></param>
        /// <param name="column"></param>
        /// <param name="file"></param>
        /// <returns></returns>
        private static void MoveWhiteSpace(char[] buffer, ref int column, StreamReader file)
        {
            while (file.ReadBlock(buffer, 0, 1) == 1 && char.IsWhiteSpace(buffer[0])) { column++; }
        }

        /// <summary>
        /// Current supported version is 2.0
        /// </summary>
        /// <param name="buffer">readbuffer</param>
        /// <param name="line">current line number</param>
        /// <param name="column"></param>
        /// <param name="file"></param>
        private static void CheckVersionNumber(char[] buffer, int line, ref int column, StreamReader file)
        {
            if (buffer[0] != '2' ||
               file.ReadBlock(buffer, 0, 2) != 2 ||
               buffer[0] != '.' ||
               buffer[1] != '0')
            {
                throw new InvalidOperationException($"Expected version 2.0 on line:{line} column: {column}");
            }
            column += 2;
        }

        /// <summary>
        /// Reads until the next line
        /// </summary>
        /// <param name="buffer">buffer to use for reading</param>
        /// <param name="line">current line number</param>
        /// <param name="column">current column number</param>
        /// <param name="file">filestream</param>
        private static void MoveNextLine(char[] buffer, ref int line, ref int column, StreamReader file)
        {
            while (file.ReadBlock(buffer, 0, 1) == 1)
            {
                if (buffer[0] == '\n')
                {
                    line++;
                    column = 0;
                    break;
                }
            }
            CheckNotEndStream(line, column, file);
        }

        /// <summary>
        /// Check that we aren't at the end of the stream
        /// </summary>
        /// <param name="line">line number</param>
        /// <param name="column">colum name</param>
        /// <param name="file">file stream</param>
        private static void CheckNotEndStream(in int line, in int column, StreamReader file)
        {
            if (file.EndOfStream)
            {
                throw new InvalidOperationException($"Unexpected EOF at line:{line} column: {column}");
            }
        }

        /// <summary>
        /// Parses the application
        /// SPEC: program: statement | program statement
        /// </summary>
        /// <param name="buffer">current buffer for reading</param>
        /// <param name="line">current line number</param>
        /// <param name="column">current collumn</param>
        /// <param name="stream">current used stream</param>
        /// <param name="operationName">current name of the operation we are parsing</param>
        /// <returns></returns>
        private static Method ParseApplication(char[] buffer, int line, int column, StreamReader stream, string operationName)
        {
            var result = new Method(operationName);
            while (true)
            {
                if (stream.ReadBlock(buffer, 0, 1) == 0)
                {
                    return result;
                }
                var letter = buffer[0];
                if (letter == '\r') { continue; } //Ignore for windows
                column++;

                #region Ignore Whitespace
                if (char.IsWhiteSpace(letter))
                {
                    if ('\n' == letter)
                    {
                        column = 0;
                        line++;
                    }
                    continue;
                }
                #endregion
                // This might be a comment
                // Missing in language Spec
                if (letter == '/')
                {
                    #region Ignore comment
                    if (stream.ReadBlock(buffer, 0, 1) == 1 && buffer[0] == '/')
                    {
                        MoveNextLine(buffer, ref line, ref column, stream);
                        continue;
                    }
                    else
                    {
                        throw new InvalidOperationException($"Expecting '//' line:{line} column: {column}");
                    }
                    #endregion
                }
                
                var token = ReadToken(buffer, ref line, stream);
                CheckNotEndStream(line, column, stream);

                /*
                 * Treating 'include', 'gate', 'opaque', 'measure', 'reset', 'if', and 'barrier' as keywords
                 * Spec doesn't define this, 
                 */
                if (token.Equals("include"))
                {
                    //Requires new methods
                    throw new NotImplementedException("requires a bit more");
                }
                //opaque is just an empty gate defintion
                else if (token.Equals("gate") || token.Equals("opaque"))
                {
                    throw new NotImplementedException("requires a bit more");
                }
                else if (token.Equals("measure"))
                {
                    throw new NotImplementedException("requires a bit more");
                }
                else if (token.Equals("reset"))
                {
                    throw new NotImplementedException("requires a bit more");
                }
                else if (token.Equals("if"))
                {
                    throw new NotImplementedException("requires a bit more");
                }
                else if (token.Equals("barrier"))
                {
                    throw new NotImplementedException("requires a bit more");
                }
                //
                else if (token.Equals("qreg"))
                {
                    result.Append(ParseQReg(buffer, ref line, ref column, stream));
                }
                else if (token.Equals("creg"))
                {
                    result.Append(ParseCReg(buffer, ref line, ref column, stream));
                }

                //Bypassing the import of qelib1.inc by making this ignore case
                if (token.Equals("CX", StringComparison.OrdinalIgnoreCase))
                {
                    result.Append(ParseCNOT(buffer, ref line, ref column, stream));
                }

            }
        }

        private static QuantumRegister ParseQReg(char[] buffer, ref int line, ref int column, StreamReader stream)
        {
            throw new NotImplementedException();
        }

        private static TraditionalRegister ParseCReg(char[] buffer, ref int line, ref int column, StreamReader stream)
        {
            throw new NotImplementedException();
        }

        private static ControledNot ParseCNOT(char[] buffer, ref int line, ref int column, StreamReader stream)
        {
            throw new NotImplementedException();
        }

        private static StringBuilder TokenBuffer = new StringBuilder();

        /// <summary>
        /// Retrieve the token
        /// </summary>
        /// <param name="buffer">current buffer</param>
        /// <param name="column">current collumn</param>
        /// <param name="stream">current used stream</param>
        /// <returns></returns>
        private static string ReadToken(char[] buffer, ref int column, StreamReader stream)
        {
            TokenBuffer.Clear();
            TokenBuffer.Append(buffer[0]);
            while (stream.ReadBlock(buffer, 0, 1) == 1 && (char.IsLetterOrDigit(buffer[0]) || buffer[0] == '_'))
            {
                column++;
                TokenBuffer.Append(buffer[0]);
            }
            return TokenBuffer.ToString();
        }
    }
}
