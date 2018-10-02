// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.CHSHGame
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Primitive;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // In 1935, three physicists - Einstein, Podolsky, and Rosen - released
    // a paper detailing an apparent contradiction in the workings of quantum
    // mechanics. The EPR Paradox (as it came to be known) posited a scenario
    // in which quantum mechanics appeared to violate Heisenberg's uncertainty
    // principle. In certain cases (later known as "entanglement"), measuring
    // a property of one particle gives you knowledge of that same property of
    // another particle; if you then measure a different property of the second
    // particle, you would learn more about the particle than is allowed by
    // Heisenberg's uncertainty principle. The EPR trio assumed that measuring
    // the first particle would have no effect on the second; in fact, it does!
    // When two particles are entangled, operations on one instantaneously
    // affect the other, which dissolves the alleged paradox. This violation of
    // local realism was deeply troubling to Einstein, and he spent much of the
    // remainder of his life trying to find an explanation which did not
    // involve "spooky action at a distance" as he called it.

    // When two particles are entangled, their measurements become correlated.
    // If you measure one of the entangled particles and it collapses to |0⟩,
    // you can be assured its counterpart also collapses to |0⟩ (or |1⟩, if
    // you entangle the particles a different way). This phenomenon happens
    // even across huge distances, and is not only faster-than-light, it's
    // instantaneous! A skeptic might raise an objection: rather than somehow
    // coordinating at the time of measurement, couldn't the particles have
    // coordinated at the time of entanglement? Decide ahead of time how they
    // would collapse, then carry that information around with them until being
    // measured. No spookiness required.

    // Such ideas are called "local hidden variable" theories, in reference to
    // the hidden information the particles carry along with them, and are
    // attractive in their simplicity. Unfortunately, their feasibility was
    // conclusively disproved by John Bell in 1964 with his famous result,
    // Bell's Theorem, which states that no theory of local hidden variables
    // can ever reproduce all the predictions of quantum mechanics. A greatly
    // simplified account of Bell's Theorem was given five years later in 1969
    // by John Clauser, Michael Horne, Abner Shimony, and Richard Holt,
    // which detailed a fascinating protocol called the CHSH Game.

    //////////////////////////////////////////////////////////////////////////
    // The CHSH Game /////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // The CHSH Game involves two players, Alice and Bob. Alice and Bob cannot
    // communicate with one another. They are each given a single random bit
    // (X to Alice and Y to Bob). Alice and Bob then output a single chosen bit
    // of their own (A from Alice and B from Bob) with the goal of making true
    // the logical formula X·Y = A ⊕ B. Since (again) Alice and Bob cannot
    // communicate, they can only hope to win some of the time. The best
    // possible classical strategy is for Alice and Bob to always output 0, no
    // matter what they get as input. This strategy wins the game 75% of the
    // time.

    // However, there's another strategy - a quantum strategy! If Alice and Bob
    // share an entangled qubit pair, they can measure their qubits and use the
    // results in a way which enables them to win an incredible 85% of the
    // time! This conclusively disproves the existence of local hidden
    // variables, because if the entangled qubits were carrying along with them
    // some information (encoded as a string of bits) then Alice and Bob could
    // have pre-shared that same information to help in their classical
    // strategy. However, because no string of bits exists which can improve
    // the classical strategy beyond a 75% success rate, there cannot
    // be such a string of bits inside the entangled qubits which enables the
    // quantum strategy to work so well: it must be something else, something
    // spookier!
    
    //////////////////////////////////////////////////////////////////////////
    // This Program //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // This program implements the CHSH quantum strategy, which is then run
    // thousands of times to compare its success rate against the classical
    // strategy. The quantum success rate converges to around 0.85 (actually
    // cos²(π/8)) while the classical success rate converges to 0.75.

    // The quantum strategy involves Alice and Bob measuring their qubits in
    // various bases depending on their input bits. Alice measures her qubit
    // in the Z basis if she is given a 0, and the X basis if she is given a 1.
    // Bob measures his qubit in similar bases, but rotated π/8 radians around
    // the unit circle. This measurement scheme ensures Alice and Bob have an
    // 85% probability of their qubits collapsing to the same value, except
    // when both X and Y are 1, in which case they have an 85% probability of
    // their qubits collapsing to *different* values - thus satisfying the 
    // X·Y = A ⊕ B formula with an 85% probability in all cases. This
    // strategy works regardless of who first measures their qubit.

    // Measurement in Bob's nonstandard bases is accomplished by first rotating
    // the state vector by π/8 radians in one direction or another, then
    // measuring in the standard computational (Z) basis.

    operation MeasureAliceQbit(bit : Bool, qubit : Qubit) : (Result)
    {
        body
        {
            if (bit)
            {
                // Measure in sign basis if bit is 1
                return Measure([PauliX], [qubit]);
            }
            else
            {
                // Measure in computational basis if bit is 0
                return Measure([PauliZ], [qubit]);
            }
        }
    }

    operation MeasureBobQbit(bit : Bool, qubit : Qubit) : (Result)
    {
        body
        {
            if (bit)
            {
                // Measure in -π/8 basis if bit is 1
                let rotation = 2.0 * PI() / 8.0;
                Ry(rotation, qubit);
                return M(qubit);
            }
            else
            {
                // Measure in π/8 basis if bit is 0
                let rotation = -2.0 * PI() / 8.0;
                Ry(rotation, qubit);
                return M(qubit);
            }
        }
    }

    operation PlayQuantumStrategy(
        aliceBit : Bool,
        bobBit : Bool,
        aliceMeasuresFirst : Bool)
        : (Bool)
    {
        body
        {
            mutable aliceResult = Zero;
            mutable bobResult = Zero;

            using (qubits = Qubit[2])
            {
                // Alice and Bob get one qubit each
                let aliceQbit = qubits[0];
                let bobQbit = qubits[1];

                // Entangle Alice & Bob's qubits
                H(aliceQbit);
                CNOT(aliceQbit, bobQbit);

                // Randomize who measures first
                if (aliceMeasuresFirst)
                {
                    set aliceResult = MeasureAliceQbit(aliceBit, aliceQbit);
                    set bobResult = MeasureBobQbit(bobBit, bobQbit);
                }
                else
                {
                    set bobResult = MeasureBobQbit(bobBit, bobQbit);
                    set aliceResult = MeasureAliceQbit(aliceBit, aliceQbit);
                }

                ResetAll(qubits);
            }

            return aliceResult == bobResult;
        }
    }
}
