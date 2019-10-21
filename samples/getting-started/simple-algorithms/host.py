import argparse
import qsharp 
from Microsoft.Quantum.Samples.SimpleAlgorithms import BernsteinVaziraniTestCase, DeutschJozsaTestCase, HiddenShiftBentCorrelationTestCase

def Bernstein_Vazirani(nqubits=4):
	for parity in range(1 << nqubits):
		measured = BernsteinVaziraniTestCase.simulate(nQubits=nqubits, patternInt=parity)
		if measured != parity:
			raise Exception('Bernstein_Vazirani', f"Measured parity {measured}, but expected {parity}.")
	print("All parities measured successfully!")

def Deutsch_Jozsa():
	balanced_test = [1, 2]
	if DeutschJozsaTestCase.simulate(nQubits=2, markedElements=balanced_test):
		raise Exception('Deutsch_Jozsa', f"Measured that test case {balanced_test} was constant!")

	constant_test = [0, 1, 2, 3, 4, 5, 6, 7]
	if not DeutschJozsaTestCase.simulate(nQubits=3, markedElements=constant_test):
		raise Exception('Deutsch_Jozsa', f"Measured that test case {constant_test} was constant!")
	print("Both constant and balanced functions measured successfully!")

def Roetteler(nqubits=4):
	for shift in range(1 << nqubits):
		measured = HiddenShiftBentCorrelationTestCase.simulate(patternInt=shift, u=nqubits/2)
		if measured != shift:
			raise Exception('Roetteler', f"Measured parity {measured}, but expected {shift}.")
	print("Measured hidden shifts successfully!")

if __name__ == "__main__":
	try:
		Bernstein_Vazirani()
		print()
		Deutsch_Jozsa()
		print()
		Roetteler()
	except Exception as e:
		func_name, message = e.args
		print(f"Error in {func_name}:  {message}")