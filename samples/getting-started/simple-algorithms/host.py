# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import qsharp
from Microsoft.Quantum.Samples.SimpleAlgorithms import BernsteinVaziraniTestCase, DeutschJozsaTestCase, HiddenShiftBentCorrelationTestCase


def bernstein_vazirani(n_qubits=4):
    """Consider a function 𝑓(𝑥⃗) on bitstrings 𝑥⃗ = (𝑥₀, …, 𝑥ₙ₋₁) of the form:

            𝑓(𝑥⃗) ≔ Σᵢ 𝑥ᵢ 𝑟ᵢ

    where 𝑟⃗ = (𝑟₀, …, 𝑟ₙ₋₁) is an unknown bitstring that determines the parity of 𝑓.
    The Bernstein–Vazirani algorithm allows determining 𝑟 given a quantum operation that implements

    |𝑥〉|𝑦〉 ↦ |𝑥〉|𝑦 ⊕ 𝑓(𝑥)〉.

    In SimpleAlgorithms.qs, we implement this algorithm as the operation BernsteinVaziraniTestCase.
    This operation takes an integer whose bits describe 𝑟, then uses those bits to construct an appropriate operation,
    and finally measures 𝑟.
    """
    for parity in range(1 << n_qubits):
        measured = BernsteinVaziraniTestCase.simulate(
            nQubits=n_qubits, patternInt=parity)
        if measured != parity:
            raise Exception(
                'Bernstein_Vazirani',
                f"Measured parity {measured}, but expected {parity}.")
    print("All parities measured successfully!")


def deutsch_jozsa():
    """A Boolean function is a function that maps bitstrings to a bit,
    𝑓 : {0, 1}^n → {0, 1}.

    We say that 𝑓 is constant if 𝑓(𝑥⃗) = 𝑓(𝑦⃗) for all bitstrings 𝑥⃗ and 𝑦⃗, and that 𝑓 is balanced if 𝑓 evaluates to true (1)
    for exactly half of its inputs.

    If we are given a function 𝑓 as a quantum operation 𝑈 |𝑥〉|𝑦〉 = |𝑥〉|𝑦 ⊕ 𝑓(𝑥)〉, and are promised that 𝑓 is either
    constant or is balanced, then the Deutsch–Jozsa algorithm decides between these cases with a single application of 𝑈.

    In SimpleAlgorithms.qs, we implement this algorithm as DeutschJozsaTestCase, following the pattern above.
    This time, however, we will pass an array to Q# indicating which elements of 𝑓 are marked; that is, should result in true.
    We check by ensuring that DeutschJozsaTestCase returns true for constant functions and false for balanced functions.
    """
    balanced_test = [1, 2]
    if DeutschJozsaTestCase.simulate(nQubits=2, markedElements=balanced_test):
        raise Exception(
            'Deutsch_Jozsa',
            f"Measured that test case {balanced_test} was constant!")

    constant_test = [0, 1, 2, 3, 4, 5, 6, 7]
    if not DeutschJozsaTestCase.simulate(
            nQubits=3, markedElements=constant_test):
        raise Exception(
            'Deutsch_Jozsa',
            f"Measured that test case {constant_test} was constant!")
    print("Both constant and balanced functions measured successfully!")


def roetteler(n_qubits=4):
    """Finally, we consider the case of finding a hidden shift 𝑠 between two Boolean functions 𝑓(𝑥) and 𝑔(𝑥) = 𝑓(𝑥 ⊕ 𝑠).

    This problem can be solved on a quantum computer with one call to each of 𝑓 and 𝑔 in the special case that both functions are
    bent; that is, that they are as far from linear as possible.

    Here, we run the test case HiddenShiftBentCorrelationTestCase defined in the matching Q# source code, and ensure that it
    correctly finds each hidden shift for a family of bent functions defined by the inner product.
    """
    for shift in range(1 << n_qubits):
        measured = HiddenShiftBentCorrelationTestCase.simulate(
            patternInt=shift, u=n_qubits / 2)
        if measured != shift:
            raise Exception(
                'Roetteler',
                f"Measured parity {measured}, but expected {shift}.")
    print("Measured hidden shifts successfully!")


if __name__ == "__main__":
    try:
        bernstein_vazirani()
        print()
        deutsch_jozsa()
        print()
        roetteler()
    except Exception as e:
        func_name, message = e.args
        print(f"Error in {func_name}:  {message}")
