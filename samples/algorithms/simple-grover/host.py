## Copyright (c) Microsoft Corporation. All rights reserved.
## Licensed under the MIT License.

# This Python script calls the ApplyGrover Q# operation
# defined in the SimpleGrover.qs file.

# For instructions on how to install the qsharp package,
# see: https://docs.microsoft.com/quantum/install-guide/python
import qsharp
from Microsoft.Quantum.Samples.SimpleGrover import SearchForMarkedInput

n_qubits = 5
result = SearchForMarkedInput.simulate(nQubits=n_qubits)
print(result)
