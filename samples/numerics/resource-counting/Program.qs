// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Numerics.Samples {

    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    operation RunProgram () : Double[] {
        let evaluationPoints = [0.0];
        let polynomialCoefficients = [0.9992759725166501, -0.16566707016968898, 0.007958079331694682, -0.0001450780334861007];
        let (odd, even) = (true, false);

        mutable msg = $"Resource counting for P(x) = {polynomialCoefficients[0]}";
        if odd {
            set msg += "*x";
        }
        for d in 1 .. Length(polynomialCoefficients) - 1 {
            set msg += " + {polynomialCoefficients[d]}*x^{d + (odd ? d+1 | 0) + (even ? d | 0)}";
        }
        Message(msg + ".");

        let pointPos = 3;
        let numBits = 32;
        return EvaluatePolynomial(
            polynomialCoefficients,
            evaluationPoints, numBits, pointPos,
            odd, even);
    }
}
