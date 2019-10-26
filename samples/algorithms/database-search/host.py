import math
import qsharp
from Microsoft.Quantum.Samples.DatabaseSearch import ApplyQuantumSearch, ApplyGroverSearch

def random_oracle():
	n = 0
	qubits = 3
	db_size = 2 ** qubits
	classic_success = 1 / db_size

	repeats = 1000
	success_count = 0
	print("Classical random search for marked element in database.")
	print(f"Database size: {db_size}.")
	print(f"Success probability:  {classic_success}.\n")

	for i in range(repeats):
		marked_qubit, db_register = ApplyQuantumSearch.simulate(nIterations=n, nDatabaseQubits=qubits)
		success_count += 1 if marked_qubit == 1 else 0
		if (i+1)%100 == 0:
			print(f"Attempt: {i}. Success: {marked_qubit},  Probability: {round(success_count / (i + 1), 3)} Found database index: {', '.join([str(x) for x in db_register])}")

def quantum_oracle():
	n = 3
	queries = n * 2 + 1
	qubits = 6
	db_size = 2 ** qubits
	classic_success = 1 / db_size
	quantum_success = math.pow(math.sin((2 * n + 1) * math.asin(1 / math.sqrt(db_size))), 2)
	repeats = 100
	success_count = 0

	print("Quantum search for marked element in database.")
	print(f"  Database Size: {db_size}")
	print(f"  Classical Success Probability: {classic_success}")
	print(f"  Queries per search: {queries}")
	print(f"  Quantum Success Probability: {quantum_success}.\n")

	for i in range(repeats):
		marked_qubit, register = ApplyQuantumSearch.simulate(nIterations=n, nDatabaseQubits=qubits)
		success_count += 1 if marked_qubit == 1 else 0

		if (i+1)%10 == 0:
			empiracle_success = round(success_count / (i+1), 3)
			speed_up = round( (empiracle_success / classic_success) / queries, 3)
			print(f"Attempt: {i} Success: {marked_qubit} Probability: {empiracle_success} Speed: {speed_up} Found database index at: {', '.join([str(x) for x in register])}")

def multiple_quantum_elements():
	n = 3
	queries = n * 2 + 1
	qubits = 8
	db_size = 2 ** qubits
	marked_elements = [0, 39, 101, 234]

	classic_success = len(marked_elements) / db_size
	quantum_success = math.pow(math.sin((2 * n + 1) * math.asin(math.sqrt(len(marked_elements)) / math.sqrt(db_size))), 2)

	repeats = 10
	success_count = 0

	print("Quantum search for marked element in database.")
	print(f"  Database size: {db_size}.")
	print(f"  Marked Elements: {', '.join([str(x) for x in marked_elements])}")
	print(f"  Classical Success Probility: {classic_success}")
	print(f"  Queries per search: {queries}")
	print(f"  Quantum success probability: {quantum_success}.\n")

	for i in range(repeats):
		marked_qubits, register = ApplyGroverSearch.simulate(markedElements=marked_elements, nIterations=n, nDatabaseQubits=qubits)

		success_count += 1 if marked_qubits == 1 else 0

		# Always true so...
		if (i+1)%1 == 0:
			empiracle_success = round(success_count / (i+1), 3)
			speed_up = round( (empiracle_success / classic_success) / queries, 3)

			print(f"Attempt: {i}. Success: {marked_qubits}, Probability: {empiracle_success} Speed up: {speed_up} Found database index: {register}")

if __name__ == "__main__":
	random_oracle()
	print("\n")
	quantum_oracle()
	print("\n")
	multiple_quantum_elements()
	print("\n\n")