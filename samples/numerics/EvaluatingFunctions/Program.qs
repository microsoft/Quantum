// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Numerics.Samples {

    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation RunProgram () : Unit {

        let evaluationPoints = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6];
        let polynomialCoefficients = [0.9992759725166501, -0.16566707016968898, 0.007958079331694682, -0.0001450780334861007];
        let (odd, even) = (true, false);

        mutable msg = $"Evaluating P(x) = {polynomialCoefficients[0]}";
        if (odd) {
            set msg += "*x";
        }
        for d in 1 .. Length(polynomialCoefficients) - 1 {
            set msg += " + {polynomialCoefficients[d]}*x^{d + (odd ? d+1 | 0) + (even ? d | 0)}";
        }
        Message(msg + ".");

        let pointPos = 3;
        let numBits = 64;
        let res = EvaluatePolynomial(
            polynomialCoefficients,
            evaluationPoints, numBits, pointPos,
            odd, even);
        for i in IndexRange(res) {
            Message($"P({evaluationPoints[i]}) = {res[i]}. [sin(x) = {Sin(evaluationPoints[i])}]");
        }

    }
}
