# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import qsharp
print("Loading the numerics library...")
# Need to load the numerics library.
qsharp.packages.add("Microsoft.Quantum.Numerics")
print("Done. Running program...")
# Refresh to make sure the file is correctly compiled.
qsharp.reload()
from Microsoft.Quantum.Numerics.Samples import EvaluatePolynomial

if __name__ == "__main__":
    # Points at which to evaluate the polynomial
    eval_points = [0]
    # Polynomial coefficients
    coefficients = [0.9992759725166501, -0.16566707016968898,
                    0.007958079331694682, -0.0001450780334861007]
    # Point position to use for the fixed-point representation
    point_position = 3
    # Number of bits to use to represent each fixed-point number
    num_bits = 32
    # If True, evaluates an odd polynomial
    odd = True
    # If True, evaluates an even polynomial
    even = False
    # This is just a string that will print out the complete polynomial.
    polynomial = f"Resource counting for P(x) = {coefficients[0]}"
    if odd:
        polynomial += "*x"
    # Further construct the polynomial string.
    for i in range(len(coefficients)):
        polynomial += f" + {coefficients[i]}* x^{i + (i + 1 if odd else 0) + (i if even else 0)}"
    # Show the polynomial.
    print(f"{polynomial}.")

    res = EvaluatePolynomial.estimate_resources(
        coefficients=coefficients,
        evaluationPoints=eval_points,
        numBits=num_bits,
        pointPos=point_position,
        odd=odd,
        even=even
    )

    print("Metric\tSum")
    for k, v in res.items():
        print(f"{k}\t{v}")
