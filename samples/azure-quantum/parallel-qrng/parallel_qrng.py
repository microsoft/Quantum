# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import sys

import qsharp
import qsharp.azure

# Print a list of Q# operations that are available to simulate or execute
# from Python.
print(qsharp.get_available_operations())

from Microsoft.Quantum.Samples import SampleRandomNumber

if __name__ == "__main__":
    # Simulate the operation locally.
    result = SampleRandomNumber.simulate()
    print(f'Local simulation result: {result}')

    # Submit the operation to an Azure Quantum workspace.
    if len(sys.argv) < 3:
        print(
            "Please provide the resource ID and location for your Azure Quantum workspace as a command-line argument.\n" +
            "E.g.: python parallel_qrng.py /subscriptions/subscription-id/Microsoft.Quantum/Workspaces/your-workspace-name \"West US\"\n" +
            "You can copy and paste the resource ID and location from the Quantum Workspace page in the Azure Portal."
        )

    else:
        resource_id = sys.argv[1]
        location = sys.argv[2]
        qsharp.azure.connect(resourceId=resource_id, location=location)
        qsharp.azure.target("ionq.simulator" if len(sys.argv) < 4 else sys.argv[3])
        result = qsharp.azure.execute(SampleRandomNumber, shots=1000, jobName="Generate a random number")
        print(f'Azure Quantum service execution result: {result}')
