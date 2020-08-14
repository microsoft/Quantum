// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Globalization;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Samples
{
    // The QPicSimulator creates text files with qpic commands. Since its
    // implementation will make heavy use of string formatting for this
    // purpose, it is convenient to use a custom formatter such that types like
    // Qubit, and Pauli can be passed as formatting arguments.
    internal sealed class QpicFormatter : IFormatProvider, ICustomFormatter
    {
        public object? GetFormat(Type? formatType) => (formatType == typeof(ICustomFormatter)) ? this : null;

        public string Format(string? fmt, object? arg, IFormatProvider? formatProvider) =>
            arg switch
            {
                Qubit q => $"q{q.Id}",
                Pauli p => p switch
                {
                    Pauli.PauliI => "I",
                    Pauli.PauliX => "X",
                    Pauli.PauliY => "Y",
                    Pauli.PauliZ => "Z",
                    _ => ""
                },
                IFormattable formattable => formattable.ToString(fmt, CultureInfo.CurrentCulture),
                null => String.Empty,
                _ => arg.ToString()
            };

        private static readonly Lazy<QpicFormatter> instance = new Lazy<QpicFormatter>(() => new QpicFormatter());

        public static QpicFormatter Instance => instance.Value;

        private QpicFormatter() {}
    }
}
