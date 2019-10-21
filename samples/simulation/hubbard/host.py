import argparse
import qsharp 
from Microsoft.Quantum.Samples.Hubbard import EstimateHubbardAntiFerromagneticEnergy

n = 6
u = 1.0
t = 0.2

precision = 7
step_size = 0.5

error = 2 ** (-1 * precision) / step_size
print("Hubbard model ground state energy estimation:")
print(f"\t{n} sites")
print(f"\t{u} repulsion term coefficient")
print(f"\t{t} hopping term coefficient")
print(f"\t{precision} bits of precision")
print(f"\t{error} energy estimate error from phase estimation alone")
print(f"\t{step_size} time step")

for i in range(10):
	energy_est = EstimateHubbardAntiFerromagneticEnergy.simulate(nSites=n, tCoefficient=t, uCoefficient=u, bitsPrecision=precision, trotterStepSize=step_size)
	print(f"Energy estimated in attempt {i}: {energy_est}")