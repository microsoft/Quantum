
namespace Microsoft.Quantum.Samples 
{
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// Returns true if qubit is $|+\rangle$ (assumes qubit is either $|+\rangle$ or $|-\rangle$)
    operation IsPlus(q: Qubit) : Bool {
        return (Measure([PauliX], [q]) == Zero);
    }

    /// # Summary
    /// Returns true if qubit is |-\rangle$ (assumes qubit is either |+\rangle$ or |-\rangle$)
    operation IsMinus(q: Qubit) : Bool {
        return (Measure([PauliX], [q]) == One);
    }

}
