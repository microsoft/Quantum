namespace Microsoft.Quantum.Canon
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;

    /// Library for classical arithmetic on complex numbers
    //open Microsoft.Quantum.Extensions.Math;

    /// Polar representation: r e^{i t}
    /// ( r, t )
    newtype ComplexPolar = (Double, Double);

    /// ToDo: type specialization for Complex vs. ComplexPolar
    function AbsSquaredComplex(input : Complex) : Double {
        let (real, imaginary) = input;
        return real * real + imaginary * imaginary;
    }

    function AbsComplex(input : Complex) : Double {
        return Sqrt(AbsSquaredComplex(input));
    }

    function ArgComplex(input : Complex) : Double {
        let (real, imaginary) = input;
        return ArcTan2(real, imaginary);
    }

    function AbsSquaredComplexPolar(input : ComplexPolar) : Double {
        let (abs, arg) = input;
        return abs * abs;
    }

    function AbsComplexPolar(input : ComplexPolar) : Double {
        let (abs, arg) = input;
        return abs;
    }

    function ArgComplexPolar(input : ComplexPolar) : Double {
        let (abs, arg) = input;
        return arg;
    }

    function ComplexPolarToCartesian(input: ComplexPolar) : Complex {
        let (abs, arg) = input;
        return Complex(abs * Cos(arg), abs * Sin(arg));
    }

    function ComplexCartesianToPolar(input: Complex) : ComplexPolar {
        return ComplexPolar(AbsComplex(input), ArgComplex(input));
    }

}
