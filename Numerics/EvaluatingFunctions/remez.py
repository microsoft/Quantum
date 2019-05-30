# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# This Python script implements Remez' algorithm (https://en.wikipedia.org/wiki/Remez_algorithm).
# To use the script, you can modify what happens when this script is executed:
# See the `if __name__ == "__main__":` branch near the end of this file.
#
# Alternatively, `run_remez` can be imported and run directly, see the docstring
# of run_remez.

import math
import numpy as np
from matplotlib import pyplot as plt

# Return n chebyshev nodes on the interval (a,b)
def _get_chebyshev_nodes(n, a, b):
    nodes = [.5 * (a + b) + .5 * (b - a) * math.cos((2 * k + 1) / (2. * n) * math.pi)
             for k in range(n)]
    return nodes

# Return the error on given nodes of a polynomial with coefficients polycoeff
# approximating the function with function values exactvals (on these nodes).
def _get_errors(exactvals, polycoeff, nodes):
    ys = np.polyval(polycoeff, nodes)
    for i in range(len(ys)):
        ys[i] = abs(ys[i] - exactvals[i])
    return ys

"""
Return the coefficients of a polynomial of degree d approximating
the function fun on the interval (a,b).

Args:
    fun: Function to approximate
    a: Left interval border
    b: Right interval border
    d: The polynomial degree will be d, 2*d or 2*d + 1 depending
        on the values of odd and even below
    odd: If True, use odd polynomial of degree 2*d+1
    even: If True, use even polynomial of degree 2*d
    tol: Tolerance to use when checking for convergence

Returns: Tuple where the first entry is the achieved absolute error
    and the second entry is a list of the polynomial coefficients in
    the order that is required by the QDK Numerics library. This is
    the inverse order compared to what np.polyval expects.
"""
def run_remez(fun, a, b, d=5, odd=False, even=False, tol=1.e-13):
    finished = False
    # initial set of points for the interpolation
    cn = _get_chebyshev_nodes(d + 2, a, b)
    # mesh on which we'll evaluate the error
    cn2 = _get_chebyshev_nodes(100 * d, a, b)

    # do at most 50 iterations and cancel if we "lose" an interpolation
    # point
    it = 0
    while not finished and len(cn) == d + 2 and it < 50:
        it += 1
        # set up the linear system of equations for Remez' algorithm
        b = np.array([fun(c) for c in cn])
        A = np.matrix(np.zeros([d + 2,d + 2]))
        for i in range(d + 2):
            x = 1.
            if odd:
                x *= cn[i]
            for j in range(d + 2):
                A[i, j] = x
                x *= cn[i]
                if odd or even:
                    x *= cn[i]
            A[i, -1] = (-1)**(i + 1)
        # this will give us a polynomial interpolation
        res = np.linalg.solve(A, b)

        # add padding for even/odd polynomials
        revlist = reversed(res[0:-1])
        sccoeff = []
        for c in revlist:
            sccoeff.append(c)
            if odd or even:
                sccoeff.append(0)
        if even:
            sccoeff = sccoeff[0:-1]
        # evaluate the approximation error
        errs = _get_errors([fun(c) for c in cn2], sccoeff, cn2)
        maximum_indices = []

        # determine points of locally maximal absolute error
        if errs[0] > errs[1]:
            maximum_indices.append(0)
        for i in range(1, len(errs) - 1):
            if errs[i] > errs[i-1] and errs[i] > errs[i+1]:
                maximum_indices.append(i)
        if errs[-1] > errs[-2]:
            maximum_indices.append(-1)

        # and choose those as new interpolation points
        # if not converged already.
        finished = True
        for idx in maximum_indices[1:]:
            if abs(errs[idx] - errs[maximum_indices[0]]) > tol:
                finished = False

        cn = [cn2[i] for i in maximum_indices]

    # plot approximation error for illustration
    plt.plot(cn2, abs(errs))
    plt.title("Plot of the approximation error")
    plt.xlabel('x')
    plt.ylabel('|poly_fit(x) - f(x)|')
    plt.show()
    return (max(abs(errs)), list(reversed(res[0:-1])))


if __name__ == "__main__":
    # the function to approximate
    def f(x):
       return math.sin(x)

    # f(x) is an odd function, so we can approximate it
    # using a polynomial of degree 2n+1
    odd = True
    even = False

    # approximate f(x) on the interval (a,b), where
    a = 0.
    b = math.pi

    # set the polynomial degree. If the function is even or odd, the polynomial
    # will be of degree `2*degree` or `2*degree + 1`, respectively.
    degree = 3

    # run Remez' algorithm
    err, coeffs = run_remez(f, a, b, degree, odd, even)

    # and output the coefficients & achieved approximation error
    oddEvenStr = ""
    if odd:
        oddEvenStr = " for odd powers of x"
    if even:
        oddEvenStr = " for even powers of x"

    print("Coefficients{}: {}".format(oddEvenStr, list(reversed(coeffs))))
    print("The polynomial achieves an L_inf error of {}.".format(err))
