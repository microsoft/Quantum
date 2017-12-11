// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;

    /// # Summary 
    /// If true, enables extra asserts that are expensive, but useful to debug the use of 
    /// the arithmetic functions.
    ///
    /// # Remarks
    /// This function allows to configure the behavior of the library. 
    function _EnableExtraAssertsForArithmetic() : Bool {
        return false;
    }

    /// # Summary
    /// Let us denote `value` by a and let y be an unsigned integer encoded in `target`,
    /// then `InPlaceXorLE` performs an operation given by the following map:
    /// |y⟩ ↦ |y⊕a⟩ , where ⊕ is the bitwise exclusive OR operator.
    ///
    /// # Input
    /// ## value
    /// An integer which is assumed to be non-negative.
    /// ## target
    /// A quantum register which is used to store `value` in little-endian encoding.
    operation InPlaceXorLE(value : Int, target : LittleEndian) : () {
        body {
            let bitrepresentation = BoolArrFromPositiveInt(value, Length(target));
            for (idx in 0..Length(target)-1) { 
                if( bitrepresentation[idx] ){
                    X(target[idx]);
                }
            }            
        }
        adjoint auto 
        controlled auto
        adjoint controlled auto
    }

    /// # Summary
    /// `MeasureInteger` reads out the content of a quantum register and converts
    /// it to an integer of type `Int`. The measurement is performed with respect
    /// to the standard computational basis, i.e., the eigenbasis of `PauliZ`.
    ///
    /// # Input
    /// ## target
    /// A quantum register which is assumed to be in little endian encoding.
    ///
    /// # Output
    /// An unsigned integer that contains the measured value of `target`.
    ///
    /// # Remarks
    /// Ensures that the register is set to 0.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.MeasureIntegerBE
    operation MeasureInteger( target : LittleEndian) : Int {
        body {
            mutable results = new Result[Length(target)]; 
            for (idx in 0..Length(target)-1) { 
                set results[idx] = MResetZ(target[idx]);
            }
            return PositiveIntFromResultArr(results);
        }
    }

    /// # Summary
    /// Version of MeasureInteger for BigEndian register
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.MeasureInteger
    operation MeasureIntegerBE( target : BigEndian) : Int {
        body {
            mutable results = new Result[Length(target)]; 
            for (idx in 0..Length(target)-1) { 
                set results[idx] = MResetZ(target[idx]);
            }
            return PositiveIntFromResultArr(Reverse(results));
        }
    }

    /// # Summary
    /// Unsigned integer increment by an integer constant, based on phase rotations.
    /// Suppose `target` encodes unsigned integer x in little-endian encoding and 
    /// `increment` is equal to a.
    /// The operation implements the unitary |x⟩ ↦ |x + a ⟩,
    /// where the addition is performed
    /// modulo 2ⁿ, for n = `Length(target)`.
    ///
    /// # Input
    /// ## target
    /// Quantum register encoding an integer using little-endian encoding in QFT basis.
    /// ## increment
    /// The integer by which the `target` is incremented by.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.IntegerIncrementLE"
    ///
    /// # References
    /// - [ *Thomas G. Draper*,
    ///      arXiv:quant-ph/0008033](https://arxiv.org/pdf/quant-ph/0008033v1.pdf)
    ///
    /// # Remarks
    /// Note that we have simplified the circuit because the increment is a classical constant,
    /// not a quantum register.
    ///
    /// See the figure on
    /// [ Page 6 of arXiv:quant-ph/0008033v1 ](https://arxiv.org/pdf/quant-ph/0008033.pdf#page=6)
    /// for the circuit diagram and explanation.
    operation IntegerIncrementPhaseLE(increment : Int, target : PhaseLittleEndian ) : () { 
        body {
            let d = Length(target);
            for( j in 0 .. d - 1 ) {
                //  Use Microsoft.Quantum.Primitive.R1Frac
                R1Frac( increment, d - 1 - j, target[j] );
            }
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    /// # Summary
    /// Asserts that the highest bit of an unsigned integer has given value
    ///
    /// # Input
    /// ## value
    /// The value of the highest bit being asserted
    /// ## number
    /// Unsigned integer of which the highest bit is checked
    ///
    /// # Remarks
    /// The controlled version of this operation ignores controls.
    operation AssertHighestBit( value : Result,  number : LittleEndian  ) : () {
        body{ 
            let mostSingificantQubit = Tail(AsQubitArray(number));
            Assert([PauliZ],[mostSingificantQubit],value, $"Most significant bit expected to be {value}");
        }
        adjoint self
        controlled( ctrls ) {
            AssertHighestBit(value,number);
        }
        controlled adjoint( ctrls ) {
            (Controlled AssertHighestBit)(ctrls,(value,number));
        }
    }

    /// # Summary
    /// Asserts that the `number` encoded in PhaseLittleEndian is less than `value`.
    ///
    /// # Input
    /// ## value
    /// `number` must be less than this.
    /// ## number
    /// Unsigned integer which is compared to `value`.
    ///
    /// # Remarks
    /// The controlled version of this operation ignores controls.
    operation AssertLessThanPhaseLE( value : Int ,  number : PhaseLittleEndian  ) : () {
        body{
            let inner = ApplyLEOperationOnPhaseLEA( AssertHighestBit(One,_), _ );
            WithA( (Adjoint IntegerIncrementPhaseLE)(value,_), inner, number );
        }
        adjoint self
        controlled( ctrls ) {
            AssertLessThanPhaseLE(value,number);
        }
        controlled adjoint( ctrls ) {
            (Controlled AssertLessThanPhaseLE)(ctrls,(value,number));
        }
    }

    /// # Summary
    /// Unsigned integer increment by an integer constant, based on phase rotations.
    /// Suppose `target` encodes unsigned integer x in little-endian encoding and 
    /// `increment` is equal to a.
    /// The operation implements the unitary |x⟩ ↦ |x + a ⟩,
    /// where the addition is performed
    /// modulo 2ⁿ, for n = `Length(target)`.
    ///
    /// # Input
    /// ## target
    /// Quantum register encoding an unsigned integer using little-endian encoding.
    /// ## increment
    /// The integer by which the `target` is incremented by
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.IntegerIncrementPhaseLE
    operation IntegerIncrementLE(increment : Int, target : LittleEndian ) : () { 
        body {
            let inner = IntegerIncrementPhaseLE(increment, _);
            ApplyPhaseLEOperationOnLECA(inner, target);
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    /// # Summary
    /// Let us denote `increment` by a, `modulus` by N and integer encoded in `target` by y
    /// Then the operation performs the following transformation:
    /// \begin{align}
    ///     \ket{y} \mapsto \ket{y + 1 \operatorname{mod} N}
    /// \end{align}
    /// Integers are encoded in little-endian format.
    ///
    /// # Input
    /// ## increment
    /// Integer increment a to be added to y.
    /// ## modulus
    /// Integer N that mods y + a.
    /// ## target
    /// Integer y in `LittleEndian` format that `increment` a is added to.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ModularIncrementPhaseLE
    ///
    /// # Remarks
    /// Assumes that the value of target is less than N. Note that
    /// <xref:microsoft.quantum.canon.modularincrementphasele> implements
    /// the same operation, but in the `PhaseLittleEndian` basis.
    operation ModularIncrementLE( increment : Int, modulus : Int,  target : LittleEndian) : () {
        body {
            let inner = ModularIncrementPhaseLE(increment, modulus, _);
            using ( ancilla = Qubit[1] ) {
                let extraZeroBit = ancilla[0];
                ApplyPhaseLEOperationOnLECA(inner, LittleEndian(target + [extraZeroBit]));
            }
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    /// # Summary
    /// Copies the most significant bit of `from` into target
    ///
    /// # Input
    /// ## from
    /// The unsigned integer from which the highest bit is copied from.
    /// the integer is encoded in little-endian format.
    /// ## target
    /// The qubit in which the highest bit is being copied. The bit encoding is
    /// in computational basis.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.LittleEndian
    operation CopyMostSignificantBitLE(
        from : LittleEndian,
        target : Qubit
        ) : () {
        body {
            let mostSingificantQubit = Tail(AsQubitArray(from));
            CNOT(mostSingificantQubit,target);
        }
        adjoint auto
    }


    /// # Summary
    /// Let us denote `increment` by a, `modulus` by N and integer encoded in `target` by y
    /// Then the operation performs the following transformation: 
    /// |y⟩ ↦ |y+a (mod N)⟩
    /// Integers are encoded in little-endian format in QFT basis
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ModularIncrementLE
    ///
    /// # Remarks
    /// Assumes that `target` has the highest bit set to 0.
    /// Also assumes that the value of target is less than N.
    ///
    /// For the circuit diagram and explanation see Figure 5 on [Page 5
    /// of arXiv:quant-ph/0205095v3](https://arxiv.org/pdf/quant-ph/0205095v3.pdf#page=5).
    operation ModularIncrementPhaseLE(
              increment : Int,
              modulus : Int,
              target : PhaseLittleEndian) : () {
        body {

            AssertBoolEqual(
                modulus <= 2 ^ (Length(target)-1), true,
                "`multiplier` must be big enough to fit integers modulo `modulus`" +
                "with highest bit set to 0" );

            if( _EnableExtraAssertsForArithmetic() ) {
                // assert that the highest bit is zero, by switching to computational basis
                ApplyLEOperationOnPhaseLEA(AssertHighestBit(Zero,_), target );
                // check that the input is less than modulus
                AssertLessThanPhaseLE(modulus, target);
            }

            using( ancilla = Qubit[1] ) {
                let lessThanModulusFlag = ancilla[0];
                let copyMostSignificantBitPhaseLE = 
                    ApplyLEOperationOnPhaseLEA(CopyMostSignificantBitLE(_,lessThanModulusFlag),_);
                // lets track the state of target register through the computation 
                IntegerIncrementPhaseLE(increment,target);
                // the state is |x+a⟩ in QFT basis 
                (Adjoint IntegerIncrementPhaseLE)(modulus,target);
                // the state is |x+a-N⟩ in QFT basis
                copyMostSignificantBitPhaseLE(target);
                // lessThanModulusFlag is set to 1 if x+a < N 
                (Controlled IntegerIncrementPhaseLE)([lessThanModulusFlag],(modulus,target));
                // the state is |x+a (mod N)⟩ in QFT basis
                // Now let us restore the lessThanModulusFlag qubit back to zero
                (Adjoint IntegerIncrementPhaseLE)(increment,target);
                X(lessThanModulusFlag);
                copyMostSignificantBitPhaseLE(target);
                IntegerIncrementPhaseLE(increment,target);
            }
        }
        adjoint auto
        controlled( controls ) {

            AssertBoolEqual( 
                modulus <= 2 ^ (Length(target)-1), true,
                "`multiplier` must be big enough to fit integers modulo `modulus`" +
                "with highest bit set to 0" );

            if( _EnableExtraAssertsForArithmetic() ) {
                // assert that the highest bit is zero, by switching to computational basis
                ApplyLEOperationOnPhaseLEA(AssertHighestBit(Zero,_), target );
                // check that the input is less than modulus
                AssertLessThanPhaseLE(modulus, target);
            }

            // note that controlled version is correct only under the assumption 
            // that the value of target is less than modulus
            using( ancilla = Qubit[1] ) {
                let lessThanModulusFlag = ancilla[0];
                let copyMostSignificantBitPhaseLE = 
                    ApplyLEOperationOnPhaseLEA(CopyMostSignificantBitLE(_,lessThanModulusFlag),_);
                // lets track the state of target register through the computation 
                (Controlled IntegerIncrementPhaseLE)(controls,(increment,target));
                // the state is |x+a⟩ in QFT basis 
                (Adjoint IntegerIncrementPhaseLE)(modulus,target);
                // the state is |x+a-N⟩ in QFT basis 
                copyMostSignificantBitPhaseLE(target);
                // lessThanModulusFlag is set to 1 if x+a < N 
                (Controlled IntegerIncrementPhaseLE)([lessThanModulusFlag],(modulus,target));
                // the state is |x+a (mod N)⟩ in QFT basis
                // Now let us restore the lessThanModulusFlag qubit back to zero
                (Controlled Adjoint IntegerIncrementPhaseLE)(controls,(increment,target));
                X(lessThanModulusFlag);
                copyMostSignificantBitPhaseLE(target);
                (Controlled IntegerIncrementPhaseLE)(controls,(increment,target));
            }
        }
        adjoint controlled auto
    }

    /// # Summary 
    /// Let us denote modulus by N, constMultiplier by a, multiplier by x  
    /// and summand by y, then this operation is given by map 
    /// |x⟩|b⟩ ↦ |x⟩| (b + a⋅x) (mod N) ⟩
    ///
    /// # Remarks
    /// - For the circuit diagram and explanation see Figure 6 on [Page 7
    ///        of arXiv:quant-ph/0205095v3](https://arxiv.org/pdf/quant-ph/0205095v3.pdf#page=7)
    /// - This operation corresponds to CMULT(a)MOD(N) in
    ///   [arXiv:quant-ph/0205095v3](https://arxiv.org/pdf/quant-ph/0205095v3.pdf)
    operation ModularAddProductLE(
              constMultiplier : Int, 
              modulus : Int, 
              multiplier : LittleEndian,
              summand : LittleEndian ) : () 
    {
        body {
            let inner = ModularAddProductPhaseLE(constMultiplier, modulus, multiplier, _ );
            using ( ancilla = Qubit[1] ) {
                let extraZeroBit = ancilla[0];
                ApplyPhaseLEOperationOnLECA(inner, LittleEndian(summand + [extraZeroBit]));    
            }
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary 
    /// The same as ModularAddProductInPlaceLE, but assumes that summand encodes 
    /// integers in QFT basis
    /// 
    /// # See Also 
    /// - Microsoft.Quantum.Canon.ModularAddProductLE
    /// 
    /// # Remarks 
    /// Assumes that `phaseSummand` has the highest bit set to 0.
    /// Also assumes that the value of `phaseSummand` is less than N.
    operation ModularAddProductPhaseLE(
              constMultiplier : Int, 
              modulus : Int, 
              multiplier : LittleEndian,
              phaseSummand : PhaseLittleEndian ) : () 
    {
        body {
            AssertBoolEqual( 
                modulus <= 2 ^ (Length(phaseSummand)-1), true,
                "`multiplier` must be big enough to fit integers modulo `modulus`" +
                "with highest bit set to 0" );

            AssertBoolEqual(
                ( constMultiplier >= 0 ) && ( constMultiplier < modulus ),
                true, "`constMultiplier` must be between 0 and `modulus`-1" );

            if( _EnableExtraAssertsForArithmetic() ) {
                // assert that the highest bit is zero, by switching to computational basis
                ApplyLEOperationOnPhaseLECA(AssertHighestBit(Zero,_), phaseSummand );
                // check that the input is less than modulus
                AssertLessThanPhaseLE(modulus, phaseSummand);
            }

            for( i in 0 .. Length(multiplier) - 1 ) {
                let summand = ( ExpMod(2,i,modulus) * constMultiplier ) % modulus;
                (Controlled ModularIncrementPhaseLE)(
                    [multiplier[i]],
                    (summand,modulus,phaseSummand) );
            }
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary 
    /// Let us denote modulus by N and constMultiplier by a 
    /// then this operation implements a unitary defined by the following map on 
    /// computational basis:
    /// |y⟩ ↦ |a⋅y (mod N) ⟩, for all y between 0 and N - 1 
    /// 
    /// # Input
    /// ## constMultiplier
    /// Constant by which multiplier is being multiplied. Must be co-prime to modulus.
    /// ## modulus
    /// The multiplication operation is performed modulo `modulus`
    /// ## multiplier
    /// The number being multiplied by a constant.
    /// This is an array of qubits representing integer in little-endian bit order.
    ///
    /// # Remarks
    /// - For the circuit diagram and explanation see Figure 7 on [Page 8
    ///        of arXiv:quant-ph/0205095v3](https://arxiv.org/pdf/quant-ph/0205095v3.pdf#page=8)
    /// - This operation corresponds to Uₐ in 
    ///   [arXiv:quant-ph/0205095v3](https://arxiv.org/pdf/quant-ph/0205095v3.pdf)
    operation ModularMultiplyByConstantLE(
              constMultiplier : Int, 
              modulus : Int,
              multiplier : LittleEndian
              ) : () 
    {
        body {
            // Check the preconditions using Microsoft.Quantum.Canon.AssertBoolEqual
            AssertBoolEqual(
                (constMultiplier >= 0) && (constMultiplier < modulus), true,
                "`constMultiplier` must be between 0 and `modulus`" );
            AssertBoolEqual( 
                modulus <= 2 ^ Length(multiplier), true,
                "`multiplier` must be big enough to fit integers modulo `modulus`" );
            AssertBoolEqual( IsCoprime(constMultiplier,modulus), true, 
                "`constMultiplier` and `modulus` must be co-prime" );

            using( summand = Qubit[Length(multiplier)] ) {

                // recall that newly allocated qubits are all in 0 state 
                // and therefore summandLE encodes 0.
                let summandLE = LittleEndian(summand);

                // Let us look at what is the result of operations below assuming 
                // multiplier is in computational basis and encodes x 
                // Currently the joint state of multiplier and summandLE is 
                // |x⟩|0⟩
                ModularAddProductLE( constMultiplier, modulus, multiplier, summandLE );
                // now the joint state is |x⟩|x⋅a(mod N)⟩

                for( i in 0 .. Length(summandLE) - 1 ) {
                    SWAP(summandLE[i],multiplier[i]);
                }
                // now the joint state is |x⋅a(mod N)⟩|x⟩

                let inverseMod = InverseMod( constMultiplier, modulus );

                // note that the operation below implements the following map:
                // |x⟩|y⟩ ↦ |x⟩|y - a⁻¹⋅x (mod N)⟩
                (Adjoint ModularAddProductLE)( inverseMod, modulus, multiplier, summandLE );
                // now the joint state is |x⋅a(mod N)⟩|x - a⁻¹⋅x⋅a (mod N)⟩ = |x⋅a(mod N)⟩|0⟩
            }
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

}

