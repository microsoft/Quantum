// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;

    /// # Summary
    /// Measures $Z \otimes Z \otimes \cdots \otimes Z$ on
    /// a given register.
    ///
    /// # Input
    /// ## register
    /// The register to be measured.
    ///
    /// # Output
    /// The result of measuring $Z \otimes Z \otimes \cdots \otimes Z$.
    operation MeasureAllZ(register : Qubit[]) : Result {
        body {
            let nQubits = Length(register);
            mutable allZMeasurement = new Pauli[nQubits];
            for (idxQubit in 0..nQubits - 1) {
                set allZMeasurement[idxQubit] = PauliZ;
            }

            return Measure(allZMeasurement, register);
        }
    }

    /// # Summary
    /// Measures the identity operator $\boldone$ on a register
    /// of qubits.
    ///
    /// # Input
    /// ## register
    /// The register to be measured.
    ///
    /// # Output
    /// The result value `Zero`.
    ///
    /// # Remarks
    /// Since $\boldone$ has only the eigenvalue $1$, and does not
    /// have a negative eigenvalue, this operation always returns
    /// `Zero`, corresponding to the eigenvalue $+1 = (-1)^0$,
    /// and does not cause a collapse of the state of `register`.
    ///
    /// On its own, this operation is not useful, but is helpful
    /// in the context of process tomography, as it provides
    /// information about the trace preservation of a quantum process.
    /// In particular, a target machine with lossy measurement should
    /// replace this operation by an actual measurement of $\boldone$.
    operation MeasureIdentity(register : Qubit[]) : Result {
        body {
            return Zero;
        }
    }

    /// # Summary
    /// Given a qubit, prepares that qubit in the maximally mixed
    /// state $\boldone / 2$ by applying the depolarizing channel
    /// $$
    /// \begin{align}
    ///     \Omega(\rho) \mathrel{:=} \frac{1}{4} \sum_{\mu \in \{0, 1, 2, 3\}} \sigma\_{\mu} \rho \sigma\_{\mu}^{\dagger},
    /// \end{align}
    /// $$
    /// where $\sigma\_i$ is the $i$th Pauli operator, and where
    /// $\rho$ is a density operator representing a mixed state.
    ///
    /// # Input
    /// ## qubit
    /// A qubit whose state is to be depolarized in the manner
    /// described above.
    ///
    /// # Remarks
    /// The mixed state $\boldone / 2$ describing the result of
    /// applying this operation to a state implicitly describes
    /// an expectation value over random choices made in this operation.
    /// Thus, for any single application, this operation maps pure states
    /// to pure states, but it acts as described in expectation.
    /// In particular, this operation can be used in process tomography
    /// to measure the *non-unital* components of a channel.
    operation PrepareSingleQubitIdentity(qubit : Qubit) : () {
        body {
            ApplyPauli([RandomSingleQubitPauli()], [qubit]);
        }
    }

    /// # Summary
    /// Given a register, prepares that register in the maximally mixed
    /// state $\boldone / 2^N$ by applying the complete depolarizing
    /// channel to each qubit, where $N$ is the length of the register.
    ///
    /// # Input
    /// ## register
    /// A register whose state is to be depolarized in the manner
    /// described above.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.preparesinglequbitidentity"
    operation PrepareIdentity(register : Qubit[]) : () {
        body {
            ApplyToEach(PrepareSingleQubitIdentity, register);
        }
    }

    /// # Summary
    /// Given a preparation and measurement, estimates the frequency
    /// with which that measurement succeeds (returns `Zero`) by
    /// performing a given number of trials.
    ///
    /// # Input
    /// ## preparation
    /// An operation $P$ that prepares a given state $\rho$ on
    /// its input register.
    /// ## measurement
    /// An operation $M$ representing the measurement of interest.
    /// ## nQubits
    /// The number of qubits on which the preparation and measurement
    /// each act.
    /// ## nMeasurements
    /// The number of times that the measurement should be performed
    /// in order to estimate the frequency of interest.
    ///
    /// # Output
    /// An estimate $\hat{p}$ of the frequency with which
    /// $M(P(\ket{00 \cdots 0}\bra{00 \cdots 0}))$ returns `Zero`,
    /// obtained using the unbiased binomial estimator $\hat{p} =
    /// n\_{\uparrow} / n\_{\text{measurements}}$, where $n\_{\uparrow}$ is
    /// the number of `Zero` results observed.
    ///
    /// This is particularly important on target machines which respect
    /// physical limitations, such that probabilities cannot be measured.
    operation EstimateFrequency(preparation : (Qubit[] => ()), measurement : (Qubit[] => Result), nQubits : Int, nMeasurements : Int) : Double {
        body {
            mutable nUp = 0;

            for (idxMeasurement in 0..nMeasurements - 1) {
                using (register = Qubit[nQubits]) {
                    preparation(register);
                    let result = measurement(register);
                    if (result == Zero) {
                        // NB!!!!! This reverses Zero and One to use conventions
                        //         common in the QCVV community. That is confusing
                        //         but is confusing with an actual purpose.
                        set nUp = nUp + 1;
                    }
                    // NB: We absolutely must reset here, since preparation()
                    //     and measurement() can each use randomness internally.
                    ApplyToEach(Reset, register);
                }
            }

            return ToDouble(nUp) / ToDouble(nMeasurements);
        }
    }

    /// # Summary
    /// Given a single qubit initially in the $\ket{0}$ state, prepares the
    /// qubit in the $+1$ eigenstate of a given Pauli operator, or in the
    /// maximally mixed state for the $\boldone$ Pauli operator `PauliI`.
    ///
    /// # Input
    /// ## basis
    /// A Pauli operator $P$ such that measuring $P$ immediately after this
    /// operation will return `Zero`.
    /// ## qubit
    /// A qubit initially in the $\ket{0}$ state which is to be prepared in
    /// the given basis.
    operation PrepareQubit(basis : Pauli, qubit : Qubit) : () {
        body {
            if (basis == PauliI) {
                PrepareSingleQubitIdentity(qubit);
            } elif (basis == PauliX) {
                H(qubit);
            } elif (basis == PauliY) {
                H(qubit);
                S(qubit);
            }
        }
    }


    /// # Summary
    /// Given two registers, prepares the maximally entangled state
    /// $\bra{\beta_{00}}\ket{\beta_{00}}$ between each pair of qubits on the respective registers,
    /// assuming that each register starts in the $\ket{0\cdots 0}$ state.
    ///
    /// # Input
    /// ## left
    /// A qubit array in the $\ket{0\cdots 0}$ state
    /// ## right
    /// A qubit array in the $\ket{0\cdots 0}$ state
    operation PrepareEntangledState(left : Qubit[], right : Qubit[]) : () {
        body {
            if (Length(left) != Length(right)) {
                fail "Left and right registers must be the same length.";
            }

            for (idxQubit in 0..Length(left) - 1) {
                H(left[idxQubit]);
                (Controlled X)([left[idxQubit]], right[idxQubit]);
            }
        }

        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Prepares the Choi–Jamiłkowski state for a given operation onto given reference
    /// and target registers.
    ///
    /// # Input
    /// ## op
    /// Operation $\Lambda$ whose Choi–Jamiłkowski state $J(\Lambda) / 2^N$
    /// is to be prepared, where $N$ is the number of qubits on which
    /// `op` acts.
    /// ## reference
    /// A register of qubits starting in the $\ket{00\cdots 0}$ state
    /// to be used as a reference for the action of `op`.
    /// ## target
    /// A register of qubits initially in the $\ket{00\cdots 0}$ state
    /// on which `op` is to be applied.
    ///
    /// # Remarks
    /// The Choi–Jamiłkowski state $J(\Lambda)$ of a quantum process is
    /// defined as
    /// $$
    /// \begin{align}
    ///     J(\Lambda) \mathrel{:=} (\boldone \otimes \Lambda)
    ///     (|\boldone\rangle\!\rangle\langle\!\langle\boldone|),
    /// \end{align}
    /// $$
    /// where $|X\rangle\!\rangle$ is the *vectorization* of a matrix $X$
    /// in the column-stacking convention. Learning a classical description
    /// of this state provides full information about the effect of $\Lambda$
    /// acting on arbitrary input states, and forms the foundation of
    /// *quantum process tomography*.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.preparechoistatec"
    /// - @"microsoft.quantum.canon.preparechoistatea"
    /// - @"microsoft.quantum.canon.preparechoistateca"
    operation PrepareChoiState(op : (Qubit[] => ()), reference : Qubit[], target : Qubit[]) : () {
        body {
            PrepareEntangledState(reference, target);
            op(target);
        }
    }

    /// # Summary
    /// Prepares the Choi–Jamiłkowski state for a given operation with a controlled variant onto given reference
    /// and target registers.
    /// # See Also
    /// - @"microsoft.quantum.canon.preparechoistate"
    operation PrepareChoiStateC(op : (Qubit[] => () : Controlled), reference : Qubit[], target : Qubit[]) : () {
        body {
            PrepareEntangledState(reference, target);
            op(target);
        }

        controlled auto
    }
    
    /// # Summary
    /// Prepares the Choi–Jamiłkowski state for a given operation with an adjoint variant onto given reference
    /// and target registers.
    /// # See Also
    /// - @"microsoft.quantum.canon.preparechoistate"
    operation PrepareChoiStateA(op : (Qubit[] => () : Adjoint), reference : Qubit[], target : Qubit[]) : () {
        body {
            PrepareEntangledState(reference, target);
            op(target);
        }

        adjoint auto
    }

    /// # Summary
    /// Prepares the Choi–Jamiłkowski state for a given operation with both controlled and adjoint variants onto given reference
    /// and target registers. 
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.preparechoistate"
    operation PrepareChoiStateCA(op : (Qubit[] => () : Controlled, Adjoint), reference : Qubit[], target : Qubit[]) : () {
        body {
            PrepareEntangledState(reference, target);
            op(target);
        }

        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    
    /// # Summary
    /// Performs a single-qubit process tomography measurement in the Pauli
    /// basis, given a particular channel of interest.
    ///
    /// # Input
    /// ## preparation
    /// The Pauli basis element $P$ in which a qubit is to be prepared.
    /// ## measurement
    /// The Pauli basis element $Q$ in which a qubit is to be measured.
    /// ## channel
    /// A single qubit channel $\Lambda$ whose behavior is being estimated
    /// with process tomography.
    ///
    /// # Output
    /// The Result `Zero` with probability
    /// $$
    /// \begin{align}
    ///     \Pr(\texttt{Zero} | \Lambda; P, Q) = \Tr\left(
    ///         \frac{\boldone + Q}{2} \Lambda\left[
    ///             \frac{\boldone + P}{2}
    ///         \right]
    ///     \right).
    /// \end{align}
    /// $$
    ///
    /// # Remarks
    /// The distribution over results returned by this operation is a special
    /// case of two-qubit state tomography. Let $\rho = J(\Lambda) / 2$ be
    /// the Choi–Jamiłkowski state for $\Lambda$. Then, the distribution above
    /// is identical to
    /// $$
    /// \begin{align}
    ///     \Pr(\texttt{Zero} | \rho; M) = \Tr(M \rho),
    /// \end{align}
    /// $$
    /// where $M = 2 (\boldone + P)^\mathrm{T} / 2 \cdot (\boldone + Q) / 2$
    /// is the effective measurement corresponding to $P$ and $Q$.
    operation SingleQubitProcessTomographyMeasurement(
        preparation : Pauli,
        measurement : Pauli,
        channel : (Qubit => ())
    ) : Result {
        body {
            mutable result = Zero;

            using (register = Qubit[1]) {
                let qubit = register[0];

                PrepareQubit(preparation, qubit);
                channel(qubit);
                set result = Measure([measurement], [qubit]);

                Reset(qubit);
            }

            return result;
        }
    }


}
