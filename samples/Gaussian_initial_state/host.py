import qsharp
from Gaussian_initial_state import gauss_wavefcn

def main():
    n_qubits = 7
    std_dev = (2**n_qubits)/6. 
    mean = 2**(n_qubits-1) - 0.5

    qubit_result = gauss_wavefcn.simulate(sigma = std_dev, mu_ = mean, num_qubits = n_qubits)
    print(qubit_result)

if __name__ == "__main__":
    main()  