// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Circuits for Doubly Controlled X gate and Doubly Controlled X up to a phase
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Introduction 
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //
    // This file contains different implementations of  Doubly Controlled X gate, also known 
    // as Toffoli gate or Doubly Controlled Not gate. 
    // The gate is equivalent to Microsoft.Quantum.Primitive.CCNOT(control1,control2,target),
    // (Controlled CNOT)([control1],control2,target) and
    // (Controlled X)([control1;control2],target).
    // On computational basis states CCNOT acts as |c₁⟩⊗|c₂⟩⊗|t⟩ ↦ |c₁⟩⊗|c₂⟩⊗|t⊕(c₁∧c₂)⟩
    // 
    // When we say that a given circuit implements CCNOT up to a phase, the means that 
    // the gate maps |c₁⟩⊗|c₂⟩⊗|t⟩ ↦ e^(iφ(c₁,c₂,t)) |c₁⟩⊗|c₂⟩⊗|t⊕(c₁∧c₂)⟩ where φ(c₁,c₂,t) 
    // is some real value
    //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary 
    /// Implementation of the CCNOT gate up to phases over the Clifford+T gate set, 
    /// according to Nielsen and Chuang, Exercise 4.26. 
    /// # References
    /// - [ *Michael A. Nielsen , Isaac L. Chuang*,
    ///     Quantum Computation and Quantum Information ](http://doi.org/10.1017/CBO9780511976667)
    /// # Recall that RFrac(P,num, pow, q) applies rotation about Pauli axis P by the fractional 
    ///   angle $$num Pi()/ 2^{pow-1}$$
    ///   In this rotations are about Y axis by the angle $$\pm Pi()/4$
    operation UpToPhaseCCNOT1 ( control1 : Qubit, control2 : Qubit, target : Qubit ) : () {
        body {
            RFrac(PauliY, -1, 3, target);
            CNOT(control1, target);
            RFrac(PauliY, -1, 3, target);
            CNOT(control2, target);
            RFrac(PauliY, 1, 3, target);
            CNOT(control1, target);
            RFrac(PauliY, 1, 3, target);
        }

        adjoint auto 
        controlled auto 
        adjoint controlled auto
    }

    /// # Summary 
    /// Implementation of the CCNOT gate up to phases over the Clifford+T gate set, 
    /// according to Selinger. On computational basis states this gate acts as 
    /// |c₁⟩⊗|c₂⟩⊗|t⟩ ↦ (-i)^(c₁∧c₂) |c₁⟩⊗|c₂⟩⊗|t⊕(c₁∧c₂)⟩.
    /// This circuit uses 4 T gates and has T depth 1 and uses one ancillary qubit
    /// # References
    /// - [ *P. Selinger*, 
    ///     Physical Review A 87: 042302 (2013)](http://doi.org/10.1103/PhysRevA.87.042302)
    /// # See Also
    /// - For the circuit diagram see Equation 9 on 
    ///   [ Page 2 of arXiv:1210.0974v2 ](https://arxiv.org/pdf/1210.0974v2.pdf#page=2)
    operation UpToPhaseCCNOT2 ( control1 : Qubit, control2 : Qubit, target : Qubit ) : () {
        body {
            using(ancillas = Qubit[1]) {
                // apply UVU† where U is outer circuit and V is inner circuit
                WithCA(
                    UpToPhaseCCNOT2OuterCircuit,
                    UpToPhaseCCNOT2InnerCircuit,
                    ancillas + [target;control1;control2]
                );
            }
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    /// # See Also 
    /// - Used as a part of @"Microsoft.Quantum.Samples.UnitTesting.UpToPhaseCCNOT2"
    /// - For the circuit diagram see Equation 9 on 
    ///   [ Page 2 of arXiv:1210.0974v2 ](https://arxiv.org/pdf/1210.0974v2.pdf#page=2)
    operation UpToPhaseCCNOT2OuterCircuit (qs : Qubit[]) : () {
        body { 
            AssertIntEqual( Length(qs), 4, "4 qubits are expected");
            H(qs[1]);
            CNOT(qs[3], qs[0]);
            CNOT(qs[1], qs[2]);
            CNOT(qs[1], qs[3]);
            CNOT(qs[2], qs[0]);
        }
        adjoint auto    
        controlled auto
        adjoint controlled auto
    }

    /// # See Also 
    /// - Used as a part of @"Microsoft.Quantum.Samples.UnitTesting.UpToPhaseCCNOT2"
    /// - For the circuit diagram see Equation 9 on 
    ///   [ Page 2 of arXiv:1210.0974v2 ](https://arxiv.org/pdf/1210.0974v2.pdf#page=2)
    operation UpToPhaseCCNOT2InnerCircuit (qs : Qubit[]) : () {
        body { 
            AssertIntEqual( Length(qs), 4, "4 qubits are expected");
            ApplyToEachCA(T,qs[0..1]);
            ApplyToEachCA((Adjoint T),qs[2..3]);
        }
        adjoint auto    
        controlled auto
        adjoint controlled auto
    }

    /// # Summary 
    /// Simple implementation of the CCNOT gate up to phases over 
    /// defined as |c₁⟩⊗|c₂⟩⊗|t⟩ ↦ (-i)^(c₁∧c₂) |c₁⟩⊗|c₂⟩⊗|t⊕(c₁∧c₂)⟩.
    operation UpToPhaseCCNOT3 ( control1 : Qubit, control2 : Qubit, target : Qubit ) : () {
        body {
            // apply |c₁⟩⊗|c₂⟩⊗|t⟩ ↦ |c₁⟩⊗|c₂⟩⊗|t⊕(c₁∧c₂)⟩.
            CCNOT(control1,control2,target); 
            // apply |c₁⟩⊗|c₂⟩ ↦ (-i)^(c₁∧c₂) |c₁⟩⊗|c₂⟩
            (Controlled Adjoint S)([control1],control2); 
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }
        
    /// # Summary
    /// Implementation of CCNOT gate over the Clifford+T gate set,
    /// according to Nielsen and Chuang Fig. 4.9
    /// # Remarks 
    /// The circuit corresponding to this implementation uses
    /// 7 T gates, 5 CNOT gates, 2 Hadamard gates, and 1 S gate and has T-depth 5. 
    /// # References
    /// - [ *Michael A. Nielsen , Isaac L. Chuang*,
    ///     Quantum Computation and Quantum Information ](http://doi.org/10.1017/CBO9780511976667)
    operation CCNOT1 ( control1 : Qubit, control2 : Qubit, target : Qubit ) : () {
        body {
            H(target);
            CNOT(control1, target);
            (Adjoint T)(target);
            CNOT(control2, target);
            T(target);
            CNOT(control1, target);
            (Adjoint T)(target);
            CNOT(control2, target);
            T(target);
            (Adjoint T)(control1);
            CNOT(control2, control1);
            H(target);
            (Adjoint T)(control1);
            CNOT(control2, control1);
            T(control2);
            S(control1);
        }
        adjoint self
        controlled auto
        adjoint controlled auto
    }

    /// #Summary 
    /// Implementation of the 3 qubit Toffoli gate over the Clifford+T gate set
    /// in T-depth 4, according to Amy et al
    /// # Remarks
    /// The circuit corresponding to this implementation uses 7 T gates, 
    /// 7 CNOT gates, 2 Hadamard gates and has T-depth 4.  
    /// # References
    /// - [ *M. Amy, D. Maslov, M. Mosca, M. Roetteler*,
    ///     IEEE Trans. CAD, 32(6): 818-830 (2013)](http://doi.org/10.1109/TCAD.2013.2244643)
    /// # See Also 
    /// - For the circuit diagram see Figure 7 (a) on  
    ///   [Page 15 of arXiv:1206.0758v3](https://arxiv.org/pdf/1206.0758v3.pdf#page=15)
    operation CCNOT2 ( control1 : Qubit, control2 : Qubit, target : Qubit ) : () {
        body {
            (Adjoint T)(control1);
            (Adjoint T)(control2);
            H(target);

            CNOT(target,control1);

            T(control1);
            CNOT(control2,target);

            CNOT(control2,control1);
            T(target);

            (Adjoint T)(control1);
            CNOT(control2,target);

            CNOT(target,control1);
            
            (Adjoint T)(target);
            T(control1);

            H(target);
            CNOT(control2,control1);
        }
        adjoint self
        controlled auto
        adjoint controlled auto
    }

    /// # Summary
    /// CCNOT gate over the Clifford+T gate set, in T-depth 1, according to Selinger
    /// # Remarks
    /// Uses 7 T gates, 7 CNOT gates, 2 Hadamard gates and has T-depth 3.  
    /// # References
    /// - [ *P. Selinger*,
    ///        Phys. Rev. A 87: 042302 (2013)](http://doi.org/10.1103/PhysRevA.87.042302)
    /// # See Also
    /// - For the circuit diagram see Figure 1 on 
    ///   [ Page 3 of arXiv:1210.0974v2 ](https://arxiv.org/pdf/1210.0974v2.pdf#page=2)
    operation TDepthOneCCNOT ( control1 : Qubit, control2 : Qubit, target : Qubit ) : () {
        body {
            using(ancillas = Qubit[4]) {
                // apply UVU† where U is outer circuit and V is inner circuit
                WithCA(
                    TDepthOneCCNOTOuterCircuit, 
                    TDepthOneCCNOTInnerCircuit, 
                    ancillas + [target; control1; control2]
                );
            }
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }
    
    /// # See Also 
    /// - Used as a part of @"Microsoft.Quantum.Samples.UnitTesting.TDepthOneCCNOT"
    /// - For the circuit diagram see Figure 1 on 
    ///   [ Page 3 of arXiv:1210.0974v2 ](https://arxiv.org/pdf/1210.0974v2.pdf#page=2)
    operation TDepthOneCCNOTOuterCircuit (qs:Qubit[]) : () {
        body { 
            AssertIntEqual( Length(qs), 7, "7 qubits are expected");
            H(qs[4]);
            CNOT(qs[5], qs[1]);
            CNOT(qs[6], qs[3]);
            CNOT(qs[5], qs[2]);
            CNOT(qs[4], qs[1]);
            CNOT(qs[3], qs[0]);
            CNOT(qs[6], qs[2]);
            CNOT(qs[4], qs[0]);
            CNOT(qs[1], qs[3]);
        }
        adjoint auto    
        controlled auto
        adjoint controlled auto
    }

    /// # See Also 
    /// - Used as a part of @"Microsoft.Quantum.Samples.UnitTesting.TDepthOneCCNOT"
    /// - For the circuit diagram see Figure 1 on 
    ///   [ Page 3 of arXiv:1210.0974v2 ](https://arxiv.org/pdf/1210.0974v2.pdf#page=2)
    operation TDepthOneCCNOTInnerCircuit (qs:Qubit[]) : () {
        body { 
            AssertIntEqual( Length(qs), 7, "7 qubits are expected");
            ApplyToEachCA((Adjoint T),qs[0..2]);
            ApplyToEachCA(T,qs[3..6]);
        }
        adjoint auto    
        controlled auto
        adjoint controlled auto
    }

    /// # Summary
    /// Implementation of the CCNOT gate over the Clifford+T gate set, with 4 T-gates,
    /// according to Jones
    /// # Remarks
    /// Uses 4 T gates, 7 CNOT gates, 2 Hadamard gates and has T-depth 3 and 1 Measurement
    /// # References
    /// - [ *N. C. Jones*, 
    ///     Phys. Rev. A 87: 022328 (2013) ](http://doi.org/10.1103/PhysRevA.87.022328)
    /// # See Also
    /// - For the circuit diagram see Figure 1 (b) 
    ///   [on Page 2 of arXiv:1212.5069v1](https://arxiv.org/pdf/1212.5069v1.pdf#page=2)
    operation CCNOT3 ( control1 : Qubit, control2 : Qubit, target : Qubit ) : () {
        body {
            using(ancillas = Qubit[1]) {
                let ancilla = ancillas[0];
                UpToPhaseCCNOT2(control1,control2,ancilla);
                S(ancilla);
                CNOT(ancilla, target);
                H(ancillas[0]);
                AssertProb([PauliZ], [ancilla], One, 0.5, "", 1e-10);
                if ( M(ancilla) == One ) { 
                    (Controlled Z)([control2], control1);
                    X(ancilla);
                }
            }
        }
        adjoint self
        // fall back to a standard multiply controlled X Implementation
        controlled( controls ) { (Controlled X)(controls + [control1;control2],target); }
        controlled adjoint auto
    }

    /// # Summary
    /// Implementation of Double Controlled Z gate in terms of exponents of Pauli operators
    /// # Remarks 
    /// Uses 7 T gates, 10 CNOTs and has T depth 5. 
    /// Note that CCZ is completely symmetric with respect to the qubit order
    /// because it acts as |abc⟩ ↦ (-1)^(a∧b∧c)|abc⟩ on computation basis states.
    /// #Recall that ExpFrac used in the circuit below is an exponent of the
    ///  respective multi-qubit Pauli gate times numerator Pi() i /2^{n-1} 
    ///  It is a primitive gate implemented by Quantum.Primitives
    operation CCZ1( qubit1 : Qubit, qubit2 : Qubit, qubit3 : Qubit ) : () {
        body {
            let register = [ qubit1; qubit2; qubit3 ];
            // note that CCZ = exp( iπ|1⟩⟨1|⊗|1⟩⟨1|⊗|1⟩⟨1| ) 
            // next use |1⟩⟨1| = (I-Z)/2 and write 
            // iπ|1⟩⟨1|⊗|1⟩⟨1|⊗|1⟩⟨1| = 
            //          = iπ/2³(I⊗I⊗I - Z⊗I⊗I - I⊗Z⊗I - I⊗I⊗Z + Z⊗Z⊗I + Z⊗I⊗Z + I⊗Z⊗Z - Z⊗Z⊗Z)
            // using above we express CCZ as: 
            ExpFrac([PauliI; PauliI; PauliI], 1, 3, register); // exp( iπ/2³I⊗I⊗I )  
            ExpFrac([PauliZ; PauliI; PauliI],-1, 3, register);
            ExpFrac([PauliI; PauliZ; PauliI],-1, 3, register);
            ExpFrac([PauliI; PauliI; PauliZ],-1, 3, register);

            ExpFrac([PauliZ; PauliZ; PauliI], 1, 3, register);
            ExpFrac([PauliZ; PauliI; PauliZ], 1, 3, register);
            ExpFrac([PauliI; PauliZ; PauliZ], 1, 3, register);

            ExpFrac([PauliZ; PauliZ; PauliZ],-1, 3, register);
        }
        adjoint self
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Implementation of the CCNOT gate using the decomposition of CCZ into the exponents of 
    /// tensor products of Z operators
    /// # Remarks 
    /// Uses 7 T gates, 10 CNOTs and two Hadamard gates and has T depth 5
    operation CCNOT4 ( control1 : Qubit, control2 : Qubit, target : Qubit ) : () {
        body {
            H(target);
            CCZ1(control1,control2,target);
            H(target);
        }
        adjoint self
        controlled auto
        controlled adjoint auto
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Implementations of CCNOT not illustrated here
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // 
    // ● implementation of CCNOT using injection of CCZ magic state. Note that CCZ magic state 
    //   can be prepared using 4 T gates.
    //
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
