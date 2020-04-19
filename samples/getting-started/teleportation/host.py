## Copyright (c) Microsoft Corporation. All rights reserved.
## Licensed under the MIT License.

## This Python script calls the TeleportRandomMessage Q# operation
## defined in the TeleportationSample.qs file.

## The first step is to import the qsharp package.
## For instructions on how to install the package, see: https://docs.microsoft.com/en-us/quantum/install-guide/python
import qsharp

# All the .qs files found under the current working directory are compiled and
# available in the workspace.
# use get_workspace_operations() to check the operations available in the current workspace:
print(qsharp.get_workspace_operations())

# these operations can be imported into Python. For example:
from Microsoft.Quantum.Samples.Teleportation import TeleportClassicalMessage, TeleportRandomMessage

# once imported, an operation can be simulated:
TeleportRandomMessage.simulate()
print("------------------")

# If the operation takes parameters, pass them as named arguments to simulate:
r = TeleportClassicalMessage.simulate(message=True)
print("Sent True, Received:", r)
r = TeleportClassicalMessage.simulate(message=False)
print("Sent False, Received:", r)
print("------------------")

# and the quantum resources needed to execute the operation can be easily estimated:
resources = TeleportRandomMessage.estimate_resources()
print("Estimated resources needed for teleport:\n", resources)
print("------------------")

# You can use these operation iteratively from Python:
for i  in range(10):
    TeleportRandomMessage.simulate()
    print("------------------")
