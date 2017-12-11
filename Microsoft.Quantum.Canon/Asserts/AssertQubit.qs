// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;

    /// # Summary
    /// Asserts that the qubit `q` is in the expected eigenstate of the Pauli $Z$ operator.
    ///
    /// # Input
    /// ## expected
    /// Which state the qubit is expected to be in: `Zero` or `One`.
    ///
    /// ## q
    /// The qubit whose state is asserted.
    ///
    /// # Remarks
    /// This is equivalent to <xref:microsoft.quantum.canon.assertqubittol> with hardcoded
    /// `tolerance=1e-5`.
    operation AssertQubit (expected: Result, q: Qubit) : ()
    {
        body 
        {
            AssertProb([PauliZ], [q], expected, 1.0, "Qubit in invalid state.", 1e-5 );
        }
    }

    /// # Summary
    /// Asserts that the qubit `q` is in the expected eigenstate of the Pauli $Z$ operator up to
    /// a given tolerance.
    ///
    /// # Input
    /// ## expected
    /// Which state the qubit is expected to be in: `Zero` or `One`.
    ///
    /// ## tolerance
    /// Tolerance on the probability of a measurement of the qubit returning the expected
    /// result.
    ///
    /// ## q
    /// The qubit whose state is asserted.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.AssertQubitState
    ///
    /// # Remarks
    /// <xref:microsoft.quantum.canon.assertqubitstate> allows for asserting
    /// arbitrary qubit states rather than only $Z$ eigenstates.
    operation AssertQubitTol (expected: Result, tolerance: Double, q: Qubit) : ()
    {
        body
        {
            AssertProb([PauliZ], [q], expected,  1.0, "Qubit One probability on Z basis failed",  tolerance);
        }
    }


    /// # Summary
    /// Asserts that the qubit given by register is in the state described by
    /// complex vector, $\ket{\psi} = \begin{bmatrix}a & b\end{bmatrix}^{\mathrm{T}}$.
    /// The first element of the tuples representing each of $a$, $b$
    /// is the real part of the complex number, while the second one is the imaginary part.
    /// The last argument defines the tolerance with which assertion is made.
    ///
    /// # Input
    /// ## expected
    /// Expected complex amplitudes for $\ket{0}$ and $\ket{1}$, respectively.
    /// ## register
    /// Qubit whose state is to be asserted. Note that this qubit is assumed to be separable
    /// from other allocated qubits, and not entangled.
    ///
    /// ## tolerance
    /// Additive tolerance by which actual amplitudes are allowed to deviate from expected.
    /// See remarks below for details.
    ///
    /// # Example
    /// ```Q#
    /// using (qubits = Qubit[2]) {
    ///     Y(qubits[1]);
    ///     // |0〉: a=(1 + 0*i), b=(0 + 0*i)
    ///     AssertQubitState(((1., 0.), (0., 0.)), qubits[0], 1e-5);
    ///     // Y |0〉 = i |1〉: a=(0 + 0*i), b=(0 + 1*i)
    ///     AssertQubitState(((0., 0.), (0., 1.)), qubits[0], 1e-5);
    /// }
    /// ```
    ///
    /// # Remarks
    /// The following Mathematica code can be used to verify expressions for mi, mx, my, mz:
    /// ```mathematica
    /// {Id, X, Y, Z} = Table[PauliMatrix[k], {k, 0, 3}];
    /// st = {{ reA + I imA }, { reB + I imB} };
    /// M = st . ConjugateTranspose[st];
    /// mx = Tr[M.X] // ComplexExpand; 
    /// my = Tr[M.Y] // ComplexExpand;
    /// mz = Tr[M.Z] // ComplexExpand; 
    /// mi = Tr[M.Id] // ComplexExpand;
    /// 2 m == Id mi + X mx + Z mz + Y my // ComplexExpand // Simplify
    /// ```
    ///
    /// The tolerance is
    /// the $L\_{\infty}$ distance between 3 dimensional real vector (x₂,x₃,x₄) defined by
    /// $\langle\psi|\psi\rangle = x\_1 I + x\_2 X + x\_3 Y + x\_4 Z$ and real vector (y₂,y₃,y₄) defined by
    /// ρ = y₁I + y₂X + y₃Y + y₄Z where ρ is the density matrix corresponding to the state of the register.
    /// This is only true under the assumption that Tr(ρ) and Tr(|ψ⟩⟨ψ|) are both 1 (e.g. x₁ = 1/2, y₁ = 1/2).
    /// If this is not the case, the function asserts that l∞ distance between
    /// (x₂-x₁,x₃-x₁,x₄-x₁,x₄+x₁) and (y₂-y₁,y₃-y₁,y₄-y₁,y₄+y₁) is less than the tolerance parameter.
    operation AssertQubitState(expected: (Complex, Complex), register: Qubit, tolerance: Double) : () {
        body {
            let (a, b) = expected;
            let (reA, imA) = a;
            let (reB, imB) = b;

            // let M be a density matrix corresponding to state. It is given by:
            // [ [ imA^2 + reA^2,                            imA imB + reA reB + I (-imB reA + imA reB) ]
            //   [imA imB + reA reB + i (imB reA - imA reB), imB^2 + reB^2                              ] ]
            // then 
            // mx = Tr(M X), where Tr is a trace function and I,X,Y,Z are Pauli matrices

            let mx = 2.0 * imA * imB + 2.0 * reA * reB;
            // my = Tr(M Y)
            let my = 2.0 * imB * reA - 2.0 * imA * reB;
            // mz = Tr(M Z)
            let mz = imA * imA - imB * imB + reA * reA - reB * reB;
            // mi = Tr(M I)
            let mi = imA * imA + imB * imB + reA * reA + reB * reB;

            // Probability of getting outcome Zero in measuring PauliZ is Tr(M(I+Z)/2) = (mi+mz)/2.0
            // Probability of getting outcome One in measuring PauliZ is Tr(M(I-Z)/2) = (mi-mz)/2.0
            // similarly, we find the probabilities for measuring PauliX,PauliY
            let tol = tolerance/2.0;
            AssertProb([PauliX], [register], Zero, (mi + mx)/2.0, "Qubit Zero probability on X basis failed", tol);
            AssertProb([PauliY], [register], Zero, (mi + my)/2.0, "Qubit Zero probability on Y basis failed", tol);
            AssertProb([PauliZ], [register], Zero, (mi + mz)/2.0, "Qubit Zero probability on Z basis failed", tol);
            AssertProb([PauliZ], [register], One,  (mi - mz)/2.0, "Qubit One probability on Z basis failed",  tol);
        }
    }

}
