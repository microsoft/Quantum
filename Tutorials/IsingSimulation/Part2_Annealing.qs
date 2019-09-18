// For and introduction to the topic, see e.g. 
// chapter 4.3 and 5.3 in https://archive.comp-phys.org/cqp.pdf.
namespace Microsoft.Quantum.Workshops.IsingSample {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;


    // Define an operation which will prepare the ground state of the driver Hamiltonian.
    //
    //       H = - Σᵢ Xᵢ.
    //
    operation PrepareInitialState(qubits : Qubit[]) : Unit
    is Adj + Ctl {

        // TODO: implement ...
    }

    /// # Summary
    /// Linearly interpolates between the initial and final system and 
    /// returns the description of the system at the time step specified by the given index. 
    function LinearInterpolation(initialSystem : TFIM1D, finalSystem : TFIM1D, (timeSteps : TimeSteps, stepIdx : Int)) : TFIM1D {
    
        let s =  IntAsDouble(stepIdx) / IntAsDouble(timeSteps::NrSteps);
        let hx = (1. - s) * initialSystem::TransverseField + s * finalSystem::TransverseField; 
        let J = (1. - s) * initialSystem::CouplingStrength + s * finalSystem::CouplingStrength;
        return TFIM1D(J, hx);
    }

    // Define an operation that will apply a sequence of Trotter steps that 
    // simulate the annealing process of an Ising system with periodic boundary conditions 
    // using a transverse field.
    //
    //     H(s) ≔ - Σ'ᵢⱼ ((1 - s) JInitial + s JFinal) Zᵢ Zⱼ - Σᵢ ((1 - s) hxInitial + s hxFinal) Xᵢ
    //
    // For `n` is the number of steps and `dt` the stepsize,
    // 
    //      define T(j) = TZZX(dt, hx(s_j), J(s_j))
    //      for s_j = j * dt / n
    //
    // and apply T(n) ... T(1) * T(0).
    //
    operation Anneal(initialSystem : TFIM1D, finalSystem : TFIM1D, timeSteps : TimeSteps, qubits : Qubit[]) : Unit
    is Adj + Ctl {

        // TODO: implement ...
    }

    // This example illustrates how to simulate the annealing process of
    // an Ising model with closed boundary conditions starting in a Hamiltonian
    //
    //       H(0) = -Σᵢ |J| Xᵢ
    //
    // and ending in a target Hamiltonian 
    //
    //       H(t) = - Σ'ᵢⱼ J Zᵢ Zⱼ
    //
    // where the primed summation Σ' is taken only over nearest-neighbors,
    // i.e.
    //
    //     H(s) ≔ - Σ'ᵢⱼ s J Zᵢ Zⱼ - Σᵢ (1 - s) |J| Xᵢ
    //
    // where s is a parameter in the interval [0, 1] that controls the
    // sweep to the final Hamiltonian.
    //
    // If s is varied sufficiently slowly, this transforms a ground state of H(0)  
    // into a ground state of H(1).
    // 
    operation IsingChainGroundState(nrSpins : Int, couplingStrength : Double, steps : TimeSteps) : Result[] {

        let initialSystem = TFIM1D(0., AbsD(couplingStrength));
        let finalSystem = TFIM1D(couplingStrength, 0.);

        using(qubits = Qubit[nrSpins]){
            
            // TODO: implement ...

            // Measures each qubit
            let measurementResults = MultiM(qubits);

            // Set all qubits to zero and return the measured values.
            ResetAll(qubits);
            return measurementResults;
        }
    }
}

