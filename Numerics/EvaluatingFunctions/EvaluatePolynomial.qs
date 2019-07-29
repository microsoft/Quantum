// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Numerics.Samples {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;

    /// # Summary
    /// Evaluates the polynomial given by `coefficients` at the
    /// evaluation points provided.
    ///
    /// # Input
    /// ## coefficients
    /// Polynomial coefficients, see Evaluate[Even/Odd/_]PolynomialFxP
    /// ## evaluationPoints
    /// Points at which to evaluate the polynomial
    /// ## numBits
    /// Number of bits to use to represent each fixed-point number
    /// ## pointPos
    /// Point position to use for the fixed-point representation
    /// ## odd
    /// If True, evaluates an odd polynomial (see EvaluateOddPolynomialFxP)
    /// ## even
    /// If True, evaluates an even polynomial (see EvaluateEvenPolynomialFxP)
    operation EvaluatePolynomial(coefficients : Double[], evaluationPoints : Double[],
                                 numBits : Int, pointPos : Int, odd : Bool, even : Bool)
                                 : Double[]
    {
        mutable results = new Double[Length(evaluationPoints)];
        for (i in IndexRange(evaluationPoints)) {
            let point = evaluationPoints[i];
            using ((xQubits, yQubits) = (Qubit[numBits], Qubit[numBits])) {
                let x = FixedPoint(pointPos, xQubits);
                let y = FixedPoint(pointPos, yQubits);
                PrepareFxP(point, x);
                if (odd) {
                    EvaluateOddPolynomialFxP(coefficients, x, y);
                }
                elif (even) {
                    EvaluateEvenPolynomialFxP(coefficients, x, y);
                }
                else {
                    EvaluatePolynomialFxP(coefficients, x, y);
                }
                set results w/= i <- MeasureFxP(y);
                ResetAll(xQubits + yQubits);
            }
        }
        return results;
    }
}