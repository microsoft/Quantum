// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Canon
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;

    // This library returns operations that prepare a specified quantum state
    // from the computational basis state $\ket{0...0}$.
    
    /// # Summary
    /// Returns a unitary operation $U$ that prepares an arbitrary quantum 
    /// state $\ket{\psi}$ with positive coefficients $\alpha_j\ge 0$ from 
    /// the $n$-qubit computational basis state $\ket{0...0}$.
    ///
    /// The action of U on a newly-allocated register is given by
    /// \begin{align}
    ///     U \ket{0\cdots 0} = \ket{\psi} = \frac{\sum^{2^n-1}_{j=0}\alpha_j \ket{j}}{\sqrt{\sum^{2^n-1}_{j=0}|\alpha_j|^2}}$.
    /// \end{align}
    ///
    /// # Input
    /// ## coefficients
    /// Array of up to $2^n$ coefficients $\alpha_j$. The $j$th coefficient 
    /// indexes the number state $\ket{j}$ encoded in big-endian format. 
    ///
    /// # Output
    /// A state-preparation unitary operation $U$.
    ///
    /// # Remarks
    /// Negative input coefficients $\alpha_j < 0$ will be treated as though
    /// positive with value $|\alpha_j|$. `coefficients` will be padded with 
    /// elements $\alpha_j = 0.0$ if fewer than $2^n$ are specified.
    ///
    /// # Example
    /// The following snippet prepares the quantum state $\ket{\psi}=\sqrt{1/8}\ket{0}+\sqrt{7/8}\ket{2}$
    /// in the qubit register `qubitsBE`.
    /// ```qsharp
    /// mutable amplitudes = [Sqrt(0.125); 0.0; Sqrt(0.875); 0.0];
    /// let op = StatePreparationPositiveCoefficients(amplitudes);
    /// using(qubits = Qubit[2]){
    ///     let qubitsBE = BigEndian(qubits);
    ///     op(qubitsBE);
    /// }
    /// ```
    function StatePreparationPositiveCoefficients(coefficients: Double[]) : (BigEndian => (): Adjoint, Controlled)
    {
        let nCoefficients = Length(coefficients);
        mutable coefficientsComplexPolar = new ComplexPolar[nCoefficients];
        for(idx in 0..nCoefficients - 1){
            set coefficientsComplexPolar[idx] = ComplexPolar(AbsD(coefficients[idx]), 0.0);
        }

        return PrepareArbitraryState(coefficientsComplexPolar, _);
    }

    /// # Summary
    /// Returns a unitary operation $U$ that prepares an arbitrary quantum 
    /// state $\ket{\psi}$ with complex coefficients $r_j e^{i t_j}$ from 
    /// the $n$-qubit computational basis state $\ket{0...0}$.
    ///
    /// The action of U on a newly-allocated register is given by
    /// \begin{align}
    /// U\ket{0...0}=\ket{\psi}=\frac{\sum^{2^n-1}_{j=0}r_j e^{i t_j}\ket{j}}{\sqrt{\sum^{2^n-1}_{j=0}|r_j|^2}}.
    /// \end{align}
    ///
    /// # Input
    /// ## coefficients
    /// Array of up to $2^n$ complex coefficients represented by their 
    /// absolute value and phase $(r_j, t_j)$. The $j$th coefficient 
    /// indexes the number state $\ket{j}$ encoded in big-endian format. 
    ///
    /// # Output
    /// A state-preparation unitary operation $U$.
    ///
    /// # Remarks
    /// Negative input coefficients $r_j < 0$ will be treated as though
    /// positive with value $|r_j|$. `coefficients` will be padded with 
    /// elements $(r_j, t_j) = (0.0, 0.0)$ if fewer than $2^n$ are 
    /// specified.
    ///
    /// # Example
    /// The following snippet prepares the quantum state $\ket{\psi}=e^{i 0.1}\sqrt{1/8}\ket{0}+\sqrt{7/8}\ket{2}$
    /// in the qubit register `qubitsBE`.
    /// ```qsharp
    /// mutable amplitudes = [Sqrt(0.125); 0.0; Sqrt(0.875); 0.0];
    /// mutable phases = [0.1; 0.0; 0.0; 0.0];
    /// mutable complexNumbers = new ComplexPolar[4];
    /// for(idx in 0..3){
    ///     set complexNumbers[idx] = ComplexPolar(amplitudes, phases);
    /// }
    /// let op = StatePreparationPositiveCoefficients(complexNumbers);
    /// using(qubits = Qubit[2]){
    ///     let qubitsBE = BigEndian(qubits);
    ///     op(qubitsBE);
    /// }
    /// ```
    function StatePreparationComplexCoefficients (coefficients: ComplexPolar[]) : (BigEndian => (): Adjoint, Controlled)
    {
        return PrepareArbitraryState(coefficients, _);
    }

    
    /// # Summary
    /// Returns a unitary operation $U$ that prepares an arbitrary quantum 
    /// state $\ket{\psi}$ with complex coefficients $r_j e^{i t_j}$ from 
    /// the $n$-qubit computational basis state $\ket{0...0}$.
    ///
    /// $U\ket{0...0}=\ket{\psi}=\frac{\sum^{2^n-1}_{j=0}r_j e^{i t_j}\ket{j}}{\sqrt{\sum^{2^n-1}_{j=0}|r_j|^2}}$.
    ///
    /// # Input
    /// ## coefficients
    /// Array of up to $2^n$ complex coefficients represented by their 
    /// absolute value and phase $(r_j, t_j)$. The $j$th coefficient 
    /// indexes the number state $\ket{j}$ encoded in big-endian format. 
    ///
    /// ## qubits
    /// Qubit register encoding number states in big-endian format. This is
    /// expected to be initialized in the computational basis state 
    /// $ket{0...0}$.
    ///
    /// # Remarks
    /// Negative input coefficients $r_j < 0$ will be treated as though
    /// positive with value $|r_j|$. `coefficients` will be padded with 
    /// elements $(r_j, t_j) = (0.0, 0.0)$ if fewer than $2^n$ are 
    /// specified.
    ///
    /// # References
    /// - Synthesis of Quantum Logic Circuits
    ///   Vivek V. Shende, Stephen S. Bullock, Igor L. Markov
    ///   https://arxiv.org/abs/quant-ph/0406176
    operation PrepareArbitraryState(coefficients: ComplexPolar[], qubits: BigEndian) : ()
    {
        body
        {
            // pad coefficients at tail length to a power of 2.
            let coefficientsPadded = Pad(-2^(Length(qubits)), ComplexPolar(0.0, 0.0), coefficients);

            let target = qubits[Length(qubits)-1];

            let op = (Adjoint PrepareArbitraryState_(coefficientsPadded, _, _))(_, target);

            if(Length(qubits) > 1){
                let control = BigEndian(qubits[0..Length(qubits)-2]);
                op(control);
            }
            else{
                let control = BigEndian(new Qubit[0]);
                op(control);
            }

        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    /// # Summary
    /// Implementation step of arbitrary state preparation procedure.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.PrepareArbitraryState
    /// - Microsoft.Quantum.Canon.MultiplexPauli
    operation PrepareArbitraryState_ (coefficients: ComplexPolar[], control: BigEndian, target: Qubit) : ()
    {
        body
        {
            // For each 2D block, compute disentangling single-qubit rotation parameters
            let (disentanglingY, disentanglingZ, newCoefficients) = StatePreparationSBMComputeCoefficients_(coefficients);
            
            MultiplexPauli(disentanglingZ, PauliZ, control, target);
            MultiplexPauli(disentanglingY, PauliY, control, target);
            // target is now in |0> state up to the phase given by arg of newCoefficients.

            // Continue recursion while there are control qubits.
            if(Length(control) == 0){
                let (abs, arg) = newCoefficients[0];
                Exp([PauliI], -1.0 * arg, [target]);
            }
            else{
                let newControl = BigEndian(control[0..Length(control)-2]);
                let newTarget = control[Length(control)-1];
                PrepareArbitraryState_(newCoefficients, newControl, newTarget);
            }
        }   
        adjoint auto
        controlled auto
        adjoint controlled auto
    }


    /// # Summary
    /// Given two complex numbers $a0, a1$, computes coordinates
    /// on the Bloch sphere such that 
    /// $a0 \ket{0} + a1 \ket{1} = r e^{it}(e^{-i \phi /2}\cos{(\theta/2)}\ket{0}+e^{i \phi /2}\sin{(\theta/2)}\ket{1})$.
    ///
    /// # Input
    /// ## a0
    /// Complex coefficient of state $\ket{0}$.
    /// ## a1
    /// Complex coefficient of state $\ket{1}$.
    ///
    /// # Output
    /// A tuple containing `(ComplexPolar(r, t), phi, theta)`.
    function BlochSphereCoordinates(a0 : ComplexPolar, a1 : ComplexPolar) : (ComplexPolar, Double, Double) {
        let abs0 = AbsComplexPolar(a0);
        let abs1 = AbsComplexPolar(a1);
        let arg0 = ArgComplexPolar(a0);
        let arg1 = ArgComplexPolar(a1);

        let r = Sqrt(abs0 * abs0 + abs1 * abs1);
        let t = 0.5 * (arg0 + arg1);
        let phi = arg1 - arg0;
        let theta = 2.0 * ArcTan2(abs1, abs0);

        return (ComplexPolar(r, t), phi, theta);
    }

    /// # Summary
    /// Implementation step of arbitrary state preparation procedure.
    /// # See Also
    /// - Microsoft.Quantum.Canon.PrepareArbitraryState
    function StatePreparationSBMComputeCoefficients_(coefficients: ComplexPolar[]) : (Double[], Double[], ComplexPolar[]) {
        mutable disentanglingZ = new Double[Length(coefficients)/2];
        mutable disentanglingY = new Double[Length(coefficients)/2];
        mutable newCoefficients = new ComplexPolar[Length(coefficients)/2];
        for(idxCoeff in 0..2..Length(coefficients) - 1){
            let (rt, phi, theta) = BlochSphereCoordinates(coefficients[idxCoeff], coefficients[idxCoeff+1]);
            set disentanglingZ[idxCoeff/2] = 0.5 * phi;
            set disentanglingY[idxCoeff/2] = 0.5 * theta;
            set newCoefficients[idxCoeff/2] = rt;
        }

        return (disentanglingY, disentanglingZ, newCoefficients);
    }
}
