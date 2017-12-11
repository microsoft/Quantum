// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
	open Microsoft.Quantum.Primitive;

    /// # Summary
    /// Represents a reflection oracle $O$, where the inputs are
    /// - The phase $\phi$ by which to rotate the reflected subspace.
    /// - The qubit register on which to perform the given reflection.
    ///
    /// # Remarks
    /// This oracle $O = \boldone - (1 - e^{i \phi}) \ket{\psi}\bra{\psi}$
    /// performs a partial reflection by a phase $\phi$ about a single pure state
    /// $\ket{\psi}$.
    newtype ReflectionOracle = ((Double, Qubit[]) => (): Adjoint, Controlled);


    // This oracle O|s>_a|ψ>_s = λ |t>_a U |ψ>_s + ... acts on the ancilla state |s>_a to implement the unitary U on any system state |ψ>_s with amplitude λ in the |t>_a basis.

    /// # Summary
    /// Represents an oracle $O$ for oblivious amplitude amplification, where 
    /// the inputs are
    /// - The ancilla register $a$ that $O$ acts on. 
    /// - The system register $s$ on which the desired unitary $U$ is applied, post-selected on register $a$ being in state $\ket{t}\_a$.
    ///
    /// # Remarks
    /// This oracle defined by
    /// $$
    ///O\ket{s}\_a\ket{\psi}\_s= \lambda\ket{t}\_a U \ket{\psi}\_s + \sqrt{1-|\lambda|^2}\ket{t^\perp}\_a\cdots
    /// $$
    /// acts on the ancilla state $\ket{s}\_a$ to implement the unitary $U$ on any system state $\ket{\psi}\_s$ with amplitude $\lambda$ in the basis flagged by $\ket{t}\_a$.
    /// The first parameter is the qubit register of $\ket{s}\_a$. The second parameter is the qubit register of $\ket{\psi}\_s$.
    newtype ObliviousOracle = ((Qubit[], Qubit[]) => (): Adjoint, Controlled);

    /// # Summary
    /// Represents an oracle $O$ for state preparation, where the inputs are
    /// - An integer indexing the flag qubit $f$.
    /// - The system register $s$ that will store the desired quantum state $\ket{\psi}\_s$.
    ///
    /// # Remarks
    /// This oracle defined by 
    /// $$
    /// O\ket{0}\_{f}\ket{0}\_s= \lambda\ket{1}\_f\ket{\psi}\_s + \sqrt{1-|\lambda|^2}\ket{0}\_f\cdots,
    /// $$
    /// acts on the on computational basis state $\ket{0}\_{f}\ket{0}\_s$ to create the target state $\ket{\psi}\_s$ with amplitude $\lambda$ in the basis flagged by $\ket{1}\_f$.
    /// The first parameter is an index to the qubit register of $\ket{0}\_f$. The second parameter encompassed both registers.
    newtype StateOracle = ((Int, Qubit[]) => (): Adjoint, Controlled);

    /// # Summary
    /// Represents an oracle $O$ for deterministic state preparation, where
    /// the input is
    /// - The register that will store the desired quantum state $\ket{\psi}\_s$.
    ///
    /// # Remarks
    /// This oracle defined by $O\ket{0}=\ket{\psi}$ acts on the on computational basis state $\ket{0}$ to create the state $\ket{\psi}$.
    /// The first parameter is the qubit register of $\ket{\psi}$.
    newtype DeterministicStateOracle = (Qubit[] => (): Adjoint, Controlled);

    /// # Summary
    /// Phases for a sequence of partial reflections in amplitude amplification.
    ///
    /// # Remarks
    /// The first parameter is an array of phases for reflection about the start state. The second parameter is an array of phases for reflection about the target state.
    /// Both arrays must be of equal length. Note that in many cases, the first phase about the start state and last phase about the target state introduces a global phase shift and may be set to $0$. 
    newtype AmpAmpReflectionPhases = (Double[], Double[]);

    /// # Summary
    /// Phases for a sequence of single-qubit rotations in amplitude amplification.
    ///
    /// # Remarks
    /// The first parameter is an array of phases for reflections, expressed as a product of single-qubit rotations.
    /// [ G.H. Low, I. L. Chuang, https://arxiv.org/abs/1707.05391].
    newtype AmpAmpRotationPhases = (Double[]);

}
