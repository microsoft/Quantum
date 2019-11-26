# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import math
import qsharp
print("Loading the numerics library...")
# Need to load the numerics library.
qsharp.packages.add("Microsoft.Quantum.Numerics")
print("Done. Running program...")
# Refresh to make sure the file is correctly compiled.
qsharp.reload()
from Microsoft.Quantum.Numerics.Samples import EvaluatePolynomial

if __name__ == "__main__":
    """Evaluates the polynomial given by `coefficients` at the evaluation points provided."""

    # Points at which to evaluate the polynomial
    eval_points = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
    # Polynomial coefficients
    coefficients = [0.9992759725166501, -0.16566707016968898,
                    0.007958079331694682, -0.0001450780334861007]
    # Point position to use for the fixed-point representation
    point_position = 3
    # Number of bits to use to represent each fixed-point number
    num_bits = 64
    # If True, evaluates an odd polynomial
    odd = True
    # If True, evaluates an even polynomial
    even = False

    # This is just a string that will print out the complete polynomial.
    polynomial = f"Evaluating P(x) = {coefficients[0]}"
    if odd:
        polynomial += "*x"
    # Further construct the polynomial string.
    for i in range(1, len(coefficients)):
        polynomial += f" + {coefficients[i]}* x^{i + (i + 1 if odd else 0) + (i if even else 0)} "
    # Show the polynomial.
    print(f"{polynomial}.")
    # Operation returns a list of results of the same length as the
    # `eval_points`. ( so len(results) == len(eval_points) )
    res = EvaluatePolynomial.toffoli_simulate(
        coefficients=coefficients,
        evaluationPoints=eval_points,
        numBits=num_bits,
        pointPos=point_position,
        odd=odd,
        even=even
    )

    for i in range(len(res)):
        print(
            f"P({eval_points[i]}) = {res[i]}.  [sin(x) = {math.sin(eval_points[i])}]")
