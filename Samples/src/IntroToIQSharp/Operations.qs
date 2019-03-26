
namespace Microsoft.Quantum.Samples 
{
    open Microsoft.Quantum.Primitive;

    /// # Summary
    /// Returns true if qubit is |+> (assumes qubit is either |+> or |->)
    operation IsPlus(q: Qubit) : Bool {
        return (Measure([PauliX], [q]) == Zero);
    }

    /// # Summary
    /// Returns true if qubit is |-> (assumes qubit is either |+> or |->)
    operation IsMinus(q: Qubit) : Bool {
        return (Measure([PauliX], [q]) == One);
    }

}