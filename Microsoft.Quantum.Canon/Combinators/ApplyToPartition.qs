// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon
{
    /// # Summary
    /// Applies a pair of operations to a given partition of a register into two parts.
    /// 
    /// # Input
    /// ## op
    /// The pair of operations to be applied to the given partition.
    /// ## numberOfQubitsToFirstArgument
    /// Number of qubits from target to put into the first part of the partition.
    /// The remaining qubits constitute the second part of the partition. 
    /// ## target
    /// A register of qubits that are being partitioned and operated on by the 
	/// given two operation. 
    ///
    /// # See Also 
    /// - @"microsoft.quantum.canon.applytopartitiona"
    /// - @"microsoft.quantum.canon.applytopartitionc"
    /// - @"microsoft.quantum.canon.applytopartitionca"
    operation ApplyToPartition(
        op : ( (Qubit[],Qubit[]) => () ),
        numberOfQubitsToFirstArgument : Int,
        target : Qubit[]
        ) : () {
        body {
            AssertBoolEqual( numberOfQubitsToFirstArgument >= 0 , true,
                "numberOfQubitsToFirstArgument must be non-negative" );
            AssertBoolEqual( Length(target) >=  numberOfQubitsToFirstArgument, true,
                "Length(target) must greater or equal to numberOfQubitsToFirstArgument" );

            op(
                target[ 0 .. numberOfQubitsToFirstArgument - 1 ],
                target[ numberOfQubitsToFirstArgument .. Length(target) - 1 ] );
        }
    }

    /// # Summary
    /// Applies a pair of operations to a given partition of a register into two parts.
    /// The modifier 'A' indicates that the operation is adjointable. 
    /// 
    /// # Input
    /// ## op
    /// The pair of operations to be applied to the given partition.
    /// ## numberOfQubitsToFirstArgument
    /// Number of qubits from target to put into the first part of the partition.
    /// The remaining qubits constitute the second part of the partition. 
    /// ## target
    /// A register of qubits that are being partitioned and operated on by the 
	/// given two operation. 
	///
    /// # See Also 
    /// - @"microsoft.quantum.canon.applytopartition"
    operation ApplyToPartitionA( 
        op : ( (Qubit[],Qubit[]) => () : Adjoint ),
        numberOfQubitsToFirstArgument : Int,
        target : Qubit[]
        ) : () {
        body{ 
            AssertBoolEqual( numberOfQubitsToFirstArgument >= 0 , true,
                "numberOfQubitsToFirstArgument must be non-negative" );
            AssertBoolEqual( Length(target) >=  numberOfQubitsToFirstArgument, true,
                "Length(target) must greater or equal to numberOfQubitsToFirstArgument" );

            op(
                target[ 0 .. numberOfQubitsToFirstArgument - 1 ],
                target[ numberOfQubitsToFirstArgument .. Length(target) - 1 ] );
        }
        adjoint auto
    }
    
    /// # Summary
    /// Applies a pair of operations to a given partition of a register into two parts.
    /// The modifier 'C' indicates that the operation is controllable. 
    /// 
    /// # Input
    /// ## op
    /// The pair of operations to be applied to the given partition.
    /// ## numberOfQubitsToFirstArgument
    /// Number of qubits from target to put into the first part of the partition.
    /// The remaining qubits constitute the second part of the partition. 
    /// ## target
    /// A register of qubits that are being partitioned and operated on by the 
	/// given two operation. 
	///
    /// # See Also 
    /// - @"microsoft.quantum.canon.applytopartition"
    operation ApplyToPartitionC( 
        op : ( (Qubit[],Qubit[]) => () : Controlled ),
        numberOfQubitsToFirstArgument : Int,
        target : Qubit[]
        ) : () {
        body{ 
            AssertBoolEqual( numberOfQubitsToFirstArgument >= 0 , true,
                "numberOfQubitsToFirstArgument must be non-negative" );
            AssertBoolEqual( Length(target) >=  numberOfQubitsToFirstArgument, true,
                "Length(target) must greater or equal to numberOfQubitsToFirstArgument" );

            op(
                target[ 0 .. numberOfQubitsToFirstArgument - 1 ],
                target[ numberOfQubitsToFirstArgument .. Length(target) - 1 ] );
        }
        controlled auto
    }

    
    /// # Summary
    /// Applies a pair of operations to a given partition of a register into two parts.
    /// The modifier 'CA' indicates that the operation is controllable and adjointable. 
    /// 
    /// # Input
    /// ## op
    /// The pair of operations to be applied to the given partition.
    /// ## numberOfQubitsToFirstArgument
    /// Number of qubits from target to put into the first part of the partition.
    /// The remaining qubits constitute the second part of the partition. 
    /// ## target
    /// A register of qubits that are being partitioned and operated on by the 
	/// given two operation. 
	///
    /// # See Also 
    /// - @"microsoft.quantum.canon.applytopartition"
    operation ApplyToPartitionCA( 
        op : ( (Qubit[],Qubit[]) => () : Controlled, Adjoint ),
        numberOfQubitsToFirstArgument : Int,
        target : Qubit[]
        ) : () {
        body{ 
            AssertBoolEqual( numberOfQubitsToFirstArgument >= 0 , true,
                "numberOfQubitsToFirstArgument must be non-negative" );
            AssertBoolEqual( Length(target) >=  numberOfQubitsToFirstArgument, true,
                "Length(target) must greater or equal to numberOfQubitsToFirstArgument" );

            op(
                target[ 0 .. numberOfQubitsToFirstArgument - 1 ],
                target[ numberOfQubitsToFirstArgument .. Length(target) - 1 ] );
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }
}
