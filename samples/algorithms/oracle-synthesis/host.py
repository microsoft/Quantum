import qsharp
from Microsoft.Quantum.Samples.OracleSynthesis import RunOracleSynthesisOnCleanTarget, RunOracleSynthesis

print("Running Synthesis on clean target...")
for i in range(256):
	res = RunOracleSynthesisOnCleanTarget.simulate(func=i, vars=3)
	if not res:
		print(f"Result = {res}")
print("Complete.\n")

print("Running Synthesis...")
for i in range(256):
	res = RunOracleSynthesis.simulate(func=i, vars=3)
	if not res:
		print(f"Result = {res}")
print("Complete.\n")