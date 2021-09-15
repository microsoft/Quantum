// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;

    // NB: Uses the naive algorithm.
    function MatrixTimesD(left : Double[][], right : Double[][]) : Double[][] {
        mutable result = ConstantArray(Length(left), ConstantArray(Length(right[0]), 0.0));

        for idxRow in 0..Length(left) - 1 {
            for idxCol in 0..Length(right[0]) - 1 {
                mutable sum = 0.0;

                for idxInner in 0..Length(left[0]) - 1 {
                    set sum += left[idxRow][idxInner] * right[idxInner][idxCol];
                }

                set result w/= idxRow <- result[idxRow] w/ idxCol <- sum;
            }
        }

        return result;
    }

    function MatrixVectorTimesD(left : Double[][], right : Double[]) : Double[] {
        mutable result = ConstantArray(Length(left), 0.0);

        for idxRow in 0..Length(left) - 1 {
            mutable sum = 0.0;

            for idxInner in 0..Length(left[0]) - 1 {
                set sum += left[idxRow][idxInner] * right[idxInner];
            }

            set result w/= idxRow <- sum;
        }

        return result;
    }

    internal function _Elementwise2(fn : ((Double, Double) -> Double), left : Double[][], right : Double[][])
    : Double[][] {
        mutable result = ConstantArray(Length(left), ConstantArray(Length(left[0]), 0.0));
        for idxRow in 0..Length(left) - 1 {
            for idxCol in 0..Length(left[0]) - 1 {
                set result w/= idxRow <- result[idxRow] w/ idxCol <- fn(left[idxRow][idxCol], right[idxRow][idxCol]);
            }
        }
        return result;
    }

    function Elementwise2(fn : (Double, Double) -> Double) : ((Double[][], Double[][]) -> Double[][]) {
        return _Elementwise2(fn, _, _);
    }

    function TimesScalarD(scalar : Double, mtx : Double[][]) : Double[][] {
        mutable result = ConstantArray(Length(mtx), ConstantArray(Length(mtx[0]), 0.0));
        for idxRow in 0..Length(mtx) - 1 {
            for idxCol in 0..Length(mtx[0]) - 1 {
                set result w/= idxRow <- result[idxRow] w/ idxCol <- scalar * mtx[idxRow][idxCol];
            }
        }
        return result;
    }

    function IdentityMatrix(n : Int) : Double[][] {
        mutable mtx = ConstantArray(n, ConstantArray(n, 0.0));
        for idx in 0..n - 1 {
            set mtx w/= idx <- mtx[idx] w/ idx <- 1.0;
        }
        return mtx;
    }

    function MatrixPow(mtx : Double[][], power : Int) : Double[][] {
        // We implement our own binary exponentiation algorithm here.
        mutable result = IdentityMatrix(Length(mtx));
        mutable runningExponent = power;
        mutable runningValue = mtx;
        while runningExponent > 0 {
            if (runningExponent &&& 1) == 1 {
                set result = MatrixTimesD(result, runningValue);
            }

            set runningValue = MatrixTimesD(runningValue, runningValue);
            set runningExponent >>>= 1;
        }
        return result;
    }

    function Binom(n : Int, k : Int) : Int {
        // Following the method of Numerical Recipes in C.
        if n < 171 {
            return Floor(0.5 + ApproximateFactorial (n) / (ApproximateFactorial (k) * ApproximateFactorial (n - k)));
        } else {
            return Floor(0.5 + ExpD(LogFactorialD(n) - LogFactorialD(k) - LogFactorialD(n - k)));
        }
    }

    // binom(½, k)
    function HalfIntegerBinom(k : Int) : Double {
        let numerator = IntAsDouble(Binom(2 * k, k)) * IntAsDouble(k % 2 == 0 ? -1 | +1);
        return numerator / (2.0 ^ IntAsDouble(2 * k) * IntAsDouble(2 * k - 1));
    }

    function InnerProduct(x : Double[], y : Double[]) : Double {
        return Fold(PlusD, 0.0, Mapped(TimesD, Zipped(x, y)));
    }

    function Projection(u : Double[], a : Double[]) : Double[] {
        let scale = InnerProduct(u, a) / InnerProduct(u, u);
        return Mapped(TimesD(scale, _), u);
    }

    function QrDecompositionD(mtx : Double[][]) : (Double[][], Double[][]) {
        // We use Gram–Schmidt decompositions to build up Q column-by-column.
        // To do so, it's easiest to build up the transpose of Q, since we'll
        // need Q^T to find R anyway.
        mutable us = [ColumnAt(0, mtx)];
        mutable es = [PNormalized(2.0, us[0])];

        for idxCol in 1..Length(mtx[0]) - 1 {
            let a = ColumnAt(idxCol, mtx);
            mutable u = a;
            for idxProj in 0..idxCol - 1 {
                let proj = Projection(us[idxProj], a);
                set u = Mapped(MinusD, Zipped(u, proj));
            }

            set us += [u];
            set es += [PNormalized(2.0, u)];
        }

        let q = Transposed(es);
        let r = MatrixTimesD(es, mtx);

        return (q, r);
    }

    function IsApproximatelyUpperTriangular(mtx : Double[][], tolerance : Double) : Bool {
        for (idxRow, row) in Enumerated(mtx) {
            for (idxCol, element) in Enumerated(row) {
                if idxRow > idxCol and AbsD(element) >= tolerance {
                    return false;
                }
            }
        }
        return true;
    }

    function IsApproximatelyZero(mtx : Double[][], tolerance : Double) : Bool {
        for row in mtx {
            for element in row {
                if AbsD(element) >= tolerance {
                    return false;
                }
            }
        }
        return true;
    }

    function IsApproximatelyNormal(mtx : Double[][], tolerance : Double) : Bool {
        return IsApproximatelyZero(Elementwise2(MinusD)(
            MatrixTimesD(mtx, Transposed(mtx)),
            MatrixTimesD(Transposed(mtx), mtx)
        ), tolerance);
    }

    function EigensystemD(mtx : Double[][]) : (Double[], Double[][]) {
        // We use the QR algorithm. It's slow in general, but is more than
        // enough for this sample.
        //
        // It also only works for normal matrices, as this computes the Schur
        // decomposition which only coincides with eigendecompositions for
        // spectral decompositions.
        if not IsApproximatelyNormal(mtx, 1e-10) {
            fail "Only currently implemented for normal matrices.";
        }
        let maxIters = 1000;
        mutable idxIter = 0;
        mutable a = mtx;
        mutable u = IdentityMatrix(Length(mtx));
        while idxIter <= maxIters {
            set idxIter += 1;
            let (q, r) = QrDecompositionD(a);
            set a = MatrixTimesD(r, q);
            set u = MatrixTimesD(u, q);
            if IsApproximatelyUpperTriangular(a, 1e-10) {
                return (Diagonal(a), u);
            }
        }

        fail $"QR algorithm did not converge to upper triangular matrix in {maxIters} iterations.";
    }

    function DiagnonalMatrix<'T>(zero : 'T, diag : 'T[]) : 'T[][] {
        mutable mtx = ConstantArray(Length(diag), ConstantArray(Length(diag), zero));
        for (idx, element) in Enumerated(diag) {
            set mtx w/= idx <- mtx[idx] w/ idx <- element;
        }
        return mtx;
    }

    function Sqrtm(mtx : Double[][]) : Double[][] {
        let (vals, vecs) = EigensystemD(mtx);
        let sqrtVals = Mapped(Sqrt, vals);
        return MatrixTimesD(vecs, MatrixTimesD(DiagnonalMatrix(0.0, sqrtVals), Transposed(vecs)));
    }

}
