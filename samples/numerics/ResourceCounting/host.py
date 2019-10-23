import qsharp

print("Loading the numerics library...")
qsharp.packages.add("microsoft.quantum.numerics")
qsharp.reload()
from Microsoft.Quantum.Numerics.Samples import EvaluatePolynomial

eval_points = [0]
coefficients = [0.9992759725166501, -0.16566707016968898, 0.007958079331694682, -0.0001450780334861007]

pointPos = 3
numBits = 32

isOdd = True
odd = isOdd
even = not isOdd
polynomial =  f"Resource counting for P(x) = {coefficients[0]}"

if isOdd:
	polynomial += "*x"

for i in range(len(coefficients)):
	polynomial += f" + {coefficients[i]}* x^{i + (i+1 if odd else 0) + (i if even else 0)}"

print(f"{polynomial}.")

res = EvaluatePolynomial.estimate_resources(coefficients=coefficients, evaluationPoints=eval_points, numBits=numBits, pointPos=pointPos, odd=odd, even=even)

print("Metric\tSum")
for k, v in res.items():
	print(f"{k}\t{v}")
