// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Canon
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;

    /// These return operations which that prepare a specified quantum state
    /// from the computational basis state $\ket{0...0}$.
    
    // TODO: type specialization of coefficients.
    // Cases: Positive, real, complex
    // TODO: parameterize choice of state preparation algorithm
    function StatePreparationPositiveCoefficients(coefficients: Double[]) : (BigEndian => (): Adjoint, Controlled)
    {
        let nCoefficients = Length(coefficients);
        let positive = true;
        mutable coefficientsComplexPolar = new ComplexPolar[nCoefficients];
        for(idx in 0..nCoefficients - 1){
            set coefficientsComplexPolar[idx] = ComplexPolar(AbsD(coefficients[idx]), 0.0);
        }

        return StatePreparationSBM(coefficientsComplexPolar, _);
    }


    function StatePreparationComplexCoefficients (coefficients: ComplexPolar[]) : (BigEndian => (): Adjoint, Controlled)
    {
        return StatePreparationSBM(coefficients, _);
    }

    /// # Remarks
    /// coefficients do not need to be normalized to one.
    operation StatePreparationSBM (coefficients: ComplexPolar[], qubits: BigEndian) : ()
    {
        body
        {
            let maxCoefficients = 2^(Length(qubits));

            if(Length(coefficients) > maxCoefficients){
                fail "Number of coefficients must be less than or equal to 2 ^ number of control.";
            }

            // zero padding of coefficients to maxCoefficients elements.
            let padZeros = new ComplexPolar[maxCoefficients - Length(coefficients)];
            
            let target = qubits[Length(qubits)-1];

            if(Length(qubits) > 1){
                let control = BigEndian(qubits[0..Length(qubits)-2]);
                (Adjoint StatePreparationSBM_(coefficients + padZeros, _, _))(control, target);
            }
            else{
                let control = BigEndian(new Qubit[0]);
                (Adjoint StatePreparationSBM_(coefficients + padZeros, _, _))(control, target);
            }
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    operation StatePreparationSBM_ (coefficients: ComplexPolar[], control: BigEndian, target: Qubit) : ()
    {
        body
        {
            // For each 2D block, compute disentangling single-qubit rotation parameters
            let (disentanglingY, disentanglingZ, newCoefficients) = StatePreparationSBMComputeCoefficients_(coefficients);
            
            MultiplexorPauli(disentanglingZ, PauliZ, control, target);
            MultiplexorPauli(disentanglingY, PauliY, control, target);
            
            // target is now in |0> state up to the phase given by arg of newCoefficients.

            // Continue recursion while there are control qubits.
            if(Length(control) == 0){
                let (abs, arg) = newCoefficients[0];
                Message($"arg {arg}");
                Exp([PauliI], -1.0 * arg, [target]);
            }
            else{
                let newControl = BigEndian(control[0..Length(control)-2]);
                let newTarget = control[Length(control)-1];
                StatePreparationSBM_(newCoefficients, newControl, newTarget);
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
    /// A `Double` tuple containing (r, t, phi, theta).
    function ComputeBlochSphereCoordinates(a0 : ComplexPolar, a1 : ComplexPolar) : (ComplexPolar, Double, Double) {
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

    function StatePreparationSBMComputeCoefficients_(coefficients: ComplexPolar[]) : (Double[], Double[], ComplexPolar[]) {
        mutable disentanglingZ = new Double[Length(coefficients)/2];
        mutable disentanglingY = new Double[Length(coefficients)/2];
        mutable newCoefficients = new ComplexPolar[Length(coefficients)/2];
        for(idxCoeff in 0..2..Length(coefficients) - 1){
            let (rt, phi, theta) = ComputeBlochSphereCoordinates(coefficients[idxCoeff], coefficients[idxCoeff+1]);
            set disentanglingZ[idxCoeff/2] = 0.5 * phi;
            set disentanglingY[idxCoeff/2] = 0.5 * theta;
            set newCoefficients[idxCoeff/2] = rt;
        }

        return (disentanglingY, disentanglingZ, newCoefficients);
    }
}
