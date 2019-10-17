import qsharp
from Microsoft.Quantum.Samples.ReversibleLogicSynthesis import SimulatePermutation,  FindHiddenShift

if __name__ == "__main__":
	perm = [_ for _ in range(7)]
	res = SimulatePermutation.simulate(perm=perm)
	print(f'Does circuit realize permutation: {res}')
	
	for shift in range(len(perm)):
		measure = FindHiddenShift.simulate(perm=perm, shift=shift)
		print(f'Applied shift = {shift}   Measured shift: {measure}')