# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import math
import qsharp
from Microsoft.Quantum.Samples.DatabaseSearch import ApplyQuantumSearch, ApplyGroverSearch

def random_oracle():
    """Let us investigate the success probability of classical random search.

    This corresponds to the case where we only prepare the start state, and
    do not perform any Grover iterates to amplify the marked subspace.
    """
    n_iterations = 0
    
    # Define the size `N` = 2^n of the database to search in terms of number of qubits
    n_qubits = 3
    db_size = 2 ** n_qubits
    
    # We now execute the classical random search and verify that the success 
    # probability matches the classical result of 1/N. Let us repeat 100
    # times to collect enough statistics.
    classical_success = 1 / db_size
    repeats = 1000
    success_count = 0

    print("Classical random search for marked element in database.")
    print(f"Database size: {db_size}.")
    print(f"Success probability:  {classical_success}.\n")

    for i in range(repeats):
        # The simulation returns a tuple  like so: (Int, List).
        marked_qubit, db_register = ApplyQuantumSearch.simulate(nIterations=n_iterations, nDatabaseQubits=n_qubits)
        success_count += 1 if marked_qubit == 1 else 0
        # Print the results of the search every 100 attempts
        if (i + 1) % 100 == 0:
            print(f"Attempt: {i}. Success: {marked_qubit},  Probability: {round(success_count / (i + 1), 3)} Found database index: {', '.join([str(x) for x in db_register])}")

def quantum_oracle():
    """Let us investigate the success probability of the quantum search.

    Now perform Grover iterates to amplify the marked subspace.
    """
    n_iterations = 3
    # Number of queries to database oracle.
    queries = n_iterations * 2 + 1
    # Define the size `N` = 2^n of the database to search in terms of number of qubits
    n_qubits = 6
    db_size = 2 ** n_qubits

    # Now execute the quantum search and verify that the success probability matches the theoretical prediction.
    classical_success = 1 / db_size
    quantum_success = math.pow(math.sin((2 * n_iterations + 1) * math.asin(1 / math.sqrt(db_size))), 2)
    repeats = 100
    success_count = 0

    print("Quantum search for marked element in database.")
    print(f"  Database Size: {db_size}")
    print(f"  Classical Success Probability: {classical_success}")
    print(f"  Queries per search: {queries}")
    print(f"  Quantum Success Probability: {quantum_success}.\n")

    for i in range(repeats):
        # The simulation returns a tuple  like so: (Int, List).
        marked_qubit, register = ApplyQuantumSearch.simulate(nIterations=n_iterations, nDatabaseQubits=n_qubits)
        success_count += 1 if marked_qubit == 1 else 0
        # Print the results of the search every 10 attempts.
        if (i + 1) % 10 == 0:
            empirical_success = round(success_count / (i + 1), 3)
            # This is how much faster the quantum algorithm performs on average over the classical search.
            speed_up = round( (empirical_success / classical_success) / queries, 3)
            print(f"Attempt: {i} Success: {marked_qubit} Probability: {empirical_success} Speed: {speed_up} Found database index at: {', '.join([str(x) for x in register])}")

def multiple_quantum_elements():
    """Let us investigate the success probability of the quantum search with multiple marked elements.
    
    We perform Grover iterates to amplify the marked subspace.
    """
    n_iterations = 3
    # Number of queries to database oracle.
    queries = n_iterations * 2 + 1
    # Define the size `N` = 2^n of the database to search in terms of number of qubits
    n_qubits = 8
    db_size = 2 ** n_qubits
    # We define the marked elements. These must be smaller than `databaseSize`.
    marked_elements = [0, 39, 101, 234]
    # Now execute the quantum search and verify that the success probability matches the theoretical prediction.
    classical_success = len(marked_elements) / db_size
    quantum_success = math.pow(math.sin((2 * n_iterations + 1) * math.asin(math.sqrt(len(marked_elements)) / math.sqrt(db_size))), 2)
    repeats = 10
    success_count = 0

    print("Quantum search for marked element in database.")
    print(f"  Database size: {db_size}.")
    print(f"  Marked Elements: {', '.join([str(x) for x in marked_elements])}")
    print(f"  Classical Success Probility: {classical_success}")
    print(f"  Queries per search: {queries}")
    print(f"  Quantum success probability: {quantum_success}.\n")

    for i in range(repeats):
        # The simulation returns a tuple  like so: (Int, List).
        marked_qubits, register = ApplyGroverSearch.simulate(markedElements=marked_elements, nIterations=n_iterations, nDatabaseQubits=n_qubits)
        success_count += 1 if marked_qubits == 1 else 0

        # Print the results of the search every attempt.
        empirical_success = round(success_count / (i + 1), 3)
        # This is how much faster the quantum algorithm performs on average over the classical search.
        speed_up = round( (empirical_success / classical_success) / queries, 3)
        print(f"Attempt: {i}. Success: {marked_qubits}, Probability: {empirical_success} Speed up: {speed_up} Found database index: {register}")

if __name__ == "__main__":
    random_oracle()
    print("\n")
    quantum_oracle()
    print("\n")
    multiple_quantum_elements()
    print("\n\n")
