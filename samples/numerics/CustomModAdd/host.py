# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import qsharp

print("Loading the numerics library...")
# Need to load the numerics library.
qsharp.packages.add("Microsoft.Quantum.Numerics")
print("Done. Running program...")
# Refresh to make sure the file is correctly compiled.
qsharp.reload()
from Microsoft.Quantum.Numerics.Samples import CustomModAdd

if __name__ == "__main__":
    """Tests a modular addition similar to the one in Fig. 4 of https://arxiv.org/pdf/quant-ph/9511018v1.pdf."""

    # List of integers to use for the first number.
    input_a = [3, 5, 3, 4, 5]
    # List of integers to use for the second number.
    input_b = [5, 4, 6, 4, 1]
    # Modulus used when adding each pair of numbers.
    mod = 7
    # Number of bits to use to represent each number.
    n = 4
    # Operation returns a list of results of the same length as the `input_a`.
    # ( so len(results) == len(input_a) )
    results = CustomModAdd.toffoli_simulate(
        inputs1=input_a, inputs2=input_b, modulus=mod, numBits=n)

    for a, b, result in zip(input_a, input_b, results):
        print(f"{a} + {b} mod {mod} = {result}.")
