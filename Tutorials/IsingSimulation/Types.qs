namespace Microsoft.Quantum.Workshops.IsingSample  {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;


    /// # Summary
    /// Describes a very simple 1D Ising chain 
    /// with uniform couplings in a transverse field.
    ///
    /// # NamedItems
    /// ## CouplingStrength
    /// The coupling strength between any two neighboring qubits along the z-axis.
    /// 
    /// ## TransverseField
    /// The field strength along the x-axis for all qubits.
    /// 
    newtype TFIM1D = (
        CouplingStrength : Double, 
        TransverseField : Double
    );

    /// # Summary
    /// Describes time evolution parameters. 
    ///
    /// # NamedItems
    /// ## Time
    /// The total evolution time.
    /// 
    /// ## NrSteps
    /// The number of steps into which to discretize the evolution time.
    /// 
    newtype TimeSteps = (
        StepSize : Double, 
        NrSteps : Int
    );
}

