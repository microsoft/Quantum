// For and introduction to the topic, see e.g. 
// chapter 4.3 and 5.3 in https://archive.comp-phys.org/cqp.pdf.
namespace Microsoft.Quantum.Workshops.IsingSample {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;


    // Define an operation which will rotate a qubit by an angle φ around X:
    //
    //    R(φ) = e^{i φ X}.
    //
    operation ApplyXTerm(phi : Double, qubit: Qubit) : Unit
    is Adj + Ctl {

        // TODO: implement ...
    }

    // Define an operation which will rotate a pair of neighbouring qubits on a line 
    // (q_j, q_{j+1}) by an angle φ around ZZ for periodic boundary conditions:
    //
    //    ZZ(φ) = e^{i φ Z_j Z_{j+1}}.
    //
    /// # Input
    /// ## siteIndex indexes the qubit j.
    operation ApplyZZTerm(phi : Double, siteIndex: Int, qubits: Qubit[]) : Unit
    is Adj + Ctl { 

        let q1 = qubits[siteIndex];
        let q2 = qubits[(siteIndex + 1) % Length(qubits)]; // periodic boundary conditions

        // TODO: implement ...
    }

    // Define an operation that will apply a single Trotter time-evolution step,
    //
    //    TZZX(dt, hx, J) = TX(dt, hx) * TZZ(dt, J)                    with 
    //    TZZ (dt, J)     = e^{i φ Z_1Z_2}e^{i φ Z_2Z_3}e^{i φ X_3}... for φ = dt * J and
    //    TX  (dt, hx)    = e^{i φ X_1}e^{i φ X_2}e^{i φ X_3}...       for φ = dt * hx
    //      
    operation TrotterStep(dt: Double, system : TFIM1D, qubits : Qubit[]) : Unit
    is Adj + Ctl {

        let indices = RangeAsIntArray(IndexRange(qubits));

        // TODO: replace with the correct term ...
        let zzTerm = NoOp<Int>;
        let xTerm = NoOp<Qubit>;

        ApplyToEachCA(zzTerm, indices);
        ApplyToEachCA(xTerm, qubits);
    }

    /// # Summary
    /// Simulates the time evolution of an 1D Ising chain with 
    /// closed boundary conditions, uniform couplings and a transverse field
    /// by applying a sequence of Trotter steps.
    ///
    ///     H = - Σ'ᵢⱼ J Zᵢ Zⱼ - Σᵢ hx Xᵢ
    ///
    /// where the primed summation Σ' is taken only over nearest-neighbors.
    operation Evolve((system : TFIM1D, timeSteps : TimeSteps), qubits : Qubit[]) : Unit
    is Adj + Ctl {

        for(idxStep in 1..timeSteps::NrSteps){
            TrotterStep(timeSteps::StepSize, system, qubits);
        }
    }
}
