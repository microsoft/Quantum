az quantum target list --output table

az quantum job submit --target-id ionq.simulator --job-name Async-GenerateRandomBits --output table -- --n-qubits=2

az quantum job output -o table --job-id 62729087-0802-41bb-aa26-081a5cef9be1