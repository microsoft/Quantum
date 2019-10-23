import qsharp

print("Loading the numerics library...")
qsharp.packages.add("microsoft.quantum.numerics")
qsharp.reload()
from Microsoft.Quantum.Numerics.Samples import CustomModAdd

input_a = [3, 5, 3, 4, 5]
input_b = [5, 4, 6, 4, 1]

mod = 7
n = 4

res = CustomModAdd.toffoli_simulate(inputs1=input_a, inputs2=input_b, modulus=mod, numBits=n)

for i in range(len(res)):
	print(f"{input_a[i]} + {input_b[i]} mod {mod} = {res[i]}.")