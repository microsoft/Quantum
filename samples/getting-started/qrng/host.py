# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This Python script contains a quantum random integer generator
# using the operation QuantumRandomNumberGenerator defined in
# the file qrng.qs.

# For instructions on how to install the qsharp package,
# see: https://docs.microsoft.com/quantum/install-guide/python

import qsharp
from Qrng import QuantumRandomNumberGenerator # We import the 
# quantum operation from the namespace defined in the file Qrng.qs
max = 50 # Here we set the maximum of our range
output = max + 1 # Variable to store the output
while output > max:
    bit_string = [] # We initialise a list to store the bits that
    # will define our random integer
    for i in range(0, max.bit_length()): # We need to call the quantum
        # operation as many times as bits are needed to define the
        # maximum of our range. For example, if max=7 we need 3 bits
        # to generate all the numbers from 0 to 7. 
        bit_string.append(QuantumRandomNumberGenerator.simulate()) 
        # Here we call the quantum operation and store the random bit
        # in the list
    output = int("".join(str(x) for x in bit_string), 2) 
# Transform bit string to integer

print("The random number generated is " + str(output))
# We print the random number
