// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Canon
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;

    // Library for classical arithmetic on complex numbers

    /// # Summary
    /// Polar representation of a complex number $c=r e^{i t}$.
    ///
    /// # Input
    /// ## First Parameter
    /// `Double` is absolute value $r \ge 0$.
    /// ## Second Parameter
    /// `Double` is the phase $t \in \mathbb R$.
    newtype ComplexPolar = (Double, Double);

    /// # Summary
    /// Returns the squared absolute value of a complex number type 
    /// `Complex`.
    ///
    /// # Input
    /// ## input
    /// Complex number $c = x + i y$.
    ///
    /// # Output
    /// Squared absolute value $|c|^2 = x^2 + y^2$.
    function AbsSquaredComplex(input : Complex) : Double {
        let (real, imaginary) = input;
        return real * real + imaginary * imaginary;
    }

    /// # Summary
    /// Returns the absolute value of a complex number type 
    /// `Complex`.
    ///
    /// # Input
    /// ## input
    /// Complex number $c = x + i y$.
    ///
    /// # Output
    /// Absolute value $|c| = \sqrt{x^2 + y^2}$.
    function AbsComplex(input : Complex) : Double {
        return Sqrt(AbsSquaredComplex(input));
    }

    /// # Summary
    /// Returns the phase of a complex number type 
    /// `Complex`.
    ///
    /// # Input
    /// ## input
    /// Complex number $c = x + i y$.
    ///
    /// # Output
    /// Phase $\text{Arg}[c] = \text{ArcTan}(y,x) \in (-\pi,\pi]$.
    function ArgComplex(input : Complex) : Double {
        let (real, imaginary) = input;
        return ArcTan2(imaginary, real);
    }

    /// # Summary
    /// Returns the squared absolute value of a complex number type 
    /// `ComplexPolar`.
    ///
    /// # Input
    /// ## input
    /// Complex number $c = r e^{i t}$.
    ///
    /// # Output
    /// Squared absolute value $|c|^2 = r^2$.
    function AbsSquaredComplexPolar(input : ComplexPolar) : Double {
        let (abs, arg) = input;
        return abs * abs;
    }

    /// # Summary
    /// Returns the absolute value of a complex number type 
    /// `ComplexPolar`.
    ///
    /// # Input
    /// ## input
    /// Complex number $c = r e^{i t}$.
    ///
    /// # Output
    /// Absolute value $|c| = r$.
    function AbsComplexPolar(input : ComplexPolar) : Double {
        let (abs, arg) = input;
        return abs;
    }

    /// # Summary
    /// Returns the phase of a complex number type 
    /// `ComplexPolar`.
    ///
    /// # Input
    /// ## input
    /// Complex number $c = r e^{i t}$.
    ///
    /// # Output
    /// Phase $\text{Arg}[c] = t$.
    function ArgComplexPolar(input : ComplexPolar) : Double {
        let (abs, arg) = input;
        return arg;
    }

    /// # Summary
    /// Converts a complex number of type `ComplexPolar` to a complex
    /// number of type `Complex`.
    ///
    /// # Input
    /// ## input
    /// Complex number $c = r e^{i t}$.
    ///
    /// # Output
    /// Complex number $c = x + i y$.
    function ComplexPolarToComplex(input: ComplexPolar) : Complex {
        let (abs, arg) = input;
        return Complex(abs * Cos(arg), abs * Sin(arg));
    }

    /// # Summary
    /// Converts a complex number of type `Complex` to a complex
    /// number of type `ComplexPolar`.
    ///
    /// # Input
    /// ## input
    /// Complex number $c = x + i y$.
    ///
    /// # Output
    /// Complex number $c = r e^{i t}$.
    function ComplexToComplexPolar(input: Complex) : ComplexPolar {
        return ComplexPolar(AbsComplex(input), ArgComplex(input));
    }

}
