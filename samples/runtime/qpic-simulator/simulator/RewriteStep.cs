// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using Microsoft.Quantum.QsCompiler;
using Microsoft.Quantum.QsCompiler.SyntaxTree;
using Microsoft.Quantum.QsCompiler.Transformations.ClassicallyControlled;

// This rewrite step invokes the `ReplaceClassicalControl` transformation to
// ensure that conditional statements are put into a canonical form and can be
// recognized in the QpicProcessor.
namespace Microsoft.Quantum.Samples
{
    class QpicRewriteStep : IRewriteStep {
        public string Name { get; } = "QpicRewriteStep";
        public int Priority { get; } = 20;
        public IDictionary<string, string> AssemblyConstants { get; } = new Dictionary<string, string>();
        public IEnumerable<IRewriteStep.Diagnostic> GeneratedDiagnostics { get; } = new List<IRewriteStep.Diagnostic>();
        public bool ImplementsPreconditionVerification { get; } = false;
        public bool ImplementsTransformation { get; } = true;
        public bool ImplementsPostconditionVerification { get; } = false;

        public bool PreconditionVerification(QsCompilation compilation) {
            throw new NotImplementedException();
        }
        
        public bool Transformation(QsCompilation compilation, out QsCompilation transformed) {
            transformed = ReplaceClassicalControl.Apply(compilation);
            return true;
        }
        
        public bool PostconditionVerification(QsCompilation compilation) {
            throw new NotImplementedException();
        }
    }
}
