// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Given an operation `op` and a bit value `bit`, applies `op` to the `target` 
    /// if `bit` is true. If false, nothing happens to the `target`.
    ///
    /// # Input
    /// ## op
    /// An operation to be conditionally applied.
    /// ## bit 
    /// a boolean that controls whether op is applied or not.
    /// ## target 
    /// The input to which the operation is applied.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The input type of the operation to be conditionally applied. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyIfC
    /// - Microsoft.Quantum.Canon.ApplyIfA
    /// - Microsoft.Quantum.Canon.ApplyIfCA
    operation ApplyIf<'T>( op : ('T => ()), bit : Bool, target : 'T) : () 
    {
        body{
            if (bit) {
            op(target);
            }
        }
    }

    /// # Summary
    /// Given an operation `op` and a bit value `bit`, applies `op` to the `target` 
    /// if `bit` is true. If false, nothing happens to the `target`.
    /// The modifier 'C' indicates that the operation is controllable.
    ///
    /// # Input
    /// ## op
    /// An operation to be conditionally applied.
    /// ## bit 
    /// a boolean that controls whether op is applied or not.
    /// ## target 
    /// The input to which the operation is applied.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The input type of the operation to be conditionally applied. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyIf
    operation ApplyIfC<'T>( op : ('T => () : Controlled), bit : Bool, target : 'T) : () 
    {
        body{
            if (bit) {
            op(target);
            }
        }

        controlled auto
    }

    /// # Summary
    /// Given an operation `op` and a bit value `bit`, applies `op` to the `target` 
    /// if `bit` is true. If false, nothing happens to the `target`.
    /// The modifier 'A' indicates that the operation is adjointable. 
    ///
    /// # Input
    /// ## op
    /// An operation to be conditionally applied.
    /// ## bit 
    /// a boolean that controls whether op is applied or not.
    /// ## target 
    /// The input to which the operation is applied.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The input type of the operation to be conditionally applied. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyIf
    operation ApplyIfA<'T>( op : ('T => () : Adjoint), bit : Bool, target : 'T) : () 
    {
        body{
            if (bit) {
            op(target);
            }
        }

        adjoint auto
    }

    /// # Summary
    /// Given an operation `op` and a bit value `bit`, applies `op` to the `target` 
    /// if `bit` is true. If false, nothing happens to the `target`.
    /// The modifier 'CA' indicates that the operation is controllable and adjointable.
    ///
    /// # Input
    /// ## op
    /// An operation to be conditionally applied.
    /// ## bit 
    /// a boolean that controls whether op is applied or not.
    /// ## target 
    /// The input to which the operation is applied.
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The input type of the operation to be conditionally applied. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyIf
    operation ApplyIfCA<'T>( op : ('T => () : Controlled, Adjoint), bit : Bool, target : 'T) : () 
    {
        body{
            if (bit) {
            op(target);
            }
        }

        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Given an operation op, returns a new operation which
    /// applies the op if a classical control bit is true. If false, nothing happens.
    ///
    /// # Input
    /// ## op
    /// An operation to be conditionally applied.
    ///
    /// # Output
    /// A new operation which is op if the classical control bit is true. 
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The input type of the operation to be conditionally applied. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ControlledC
    /// - Microsoft.Quantum.Canon.ControlledA
    /// - Microsoft.Quantum.Canon.ControlledCA
    function CControlled<'T>( op : ('T => ())) : ((Bool, 'T) => ()) 
    {
        return ApplyIf(op, _, _);
    }

    /// # Summary
    /// Given an operation op, returns a new operation which
    /// applies the op if a classical control bit is true. If false, nothing happens.
    /// The modifier 'C' indicates that the operation is controllable.
    ///
    /// # Input
    /// ## op
    /// An operation to be conditionally applied.
    ///
    /// # Output
    /// A new operation which is op if the classical control bit is true. 
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The input type of the operation to be conditionally applied. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.Controlled
    function CControlledC<'T>( op : ('T => () : Controlled)) : ((Bool, 'T) => () : Controlled) 
    {
        return ApplyIfC(op, _, _);
    }

    /// # Summary
    /// Given an operation op, returns a new operation which
    /// applies the op if a classical control bit is true. If false, nothing happens.
    /// The modifier 'A' indicates that the operation is adjointable. 
    ///
    /// # Input
    /// ## op
    /// An operation to be conditionally applied.
    ///
    /// # Output
    /// A new operation which is op if the classical control bit is true. 
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The input type of the operation to be conditionally applied. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.Controlled
    function CControlledA<'T>( op : ('T => () : Adjoint)) : ((Bool, 'T) => () : Adjoint) 
    {
        return ApplyIfA(op, _, _);
    }

    /// # Summary
    /// Given an operation op, returns a new operation which
    /// applies the op if a classical control bit is true. If false, nothing happens.
    /// The modifier 'CA' indicates that the operation is controllable and adjointable.
    ///
    /// # Input
    /// ## op
    /// An operation to be conditionally applied.
    ///
    /// # Output
    /// A new operation which is op if the classical control bit is true. 
    ///
    /// # Type Parameters
    /// ## 'T 
    /// The input type of the operation to be conditionally applied. 
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.Controlled
    function CControlledCA<'T>( op : ('T => (): Controlled, Adjoint)) : ((Bool, 'T) => (): Controlled, Adjoint) 
    {
        return ApplyIfCA(op, _, _);
    }

}
