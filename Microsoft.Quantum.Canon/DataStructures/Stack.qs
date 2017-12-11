// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// A last-in-first-out stack of `Result` variables.
    /// The stack consists of an integer capacity, a stack pointer and a `Result` array.
    newtype ResultStack = (Int,  Int, Result[]);

    /// # Summary
    /// Retrieves the capacity of a <xref:microsoft.quantum.canon.resultstack>.
    ///
    /// # Input
    /// ## stack
    /// The stack whose capacity is to be determined.
    ///
    /// # Output
    /// The number of elements fitting into the stack.
    function StackCapacity(stack : ResultStack) : Int {
        let (size, pos, data) = stack;
        return size;
    }

    /// # Summary
    /// Retrieves the number of elements stored in a
    /// <xref:microsoft.quantum.canon.resultstack>.
    ///
    /// # Input
    /// ## stack
    /// The stack whose length is to be determined.
    ///
    /// # Output
    /// The number of elements on the stack.
    function StackLength(stack : ResultStack) : Int {
        let (size, pos, data) = stack;
        return pos;
    }

    /// # Summary
    /// Removes the topmost element from a <xref:microsoft.quantum.canon.resultstack>.
    ///
    /// # Input
    /// ## stack
    /// The stack to be popped.
    ///
    /// # Output
    /// The `stack` with the top element removed. The new stack has the same capacity as
    /// the old one, but its length is reduced by one.
    function StackPop(stack : ResultStack) : (ResultStack) {
        let (size, pos, data) = stack;
        if (pos == 0) {
            fail "Cannot pop an empty stack.";
        }
        return ResultStack(size, pos - 1, data);
    }

    /// # Summary
    /// Pushes a new element onto a <xref:microsoft.quantum.canon.resultstack>.
    ///
    /// # Input
    /// ## stack
    /// The stack to be grown.
    /// ## datum
    /// The `Result` value to be pushed onto `stack`.
    ///
    /// # Output
    /// The `stack` with `datum` added as its new top element. The new stack's length is
    /// increased by one.
    function StackPush(stack : ResultStack, datum : Result) : ResultStack {
        let (size, pos, data) = stack;
        if (pos == size) {
            fail "Stack is full.";
        }
        
        // FIXME: implies an O(n) copy!
        //        This could be fixed by using a native C# operation to
        //        wrap ImmutableStack<T>.
        // See also: https://msdn.microsoft.com/en-us/library/dn467197(v=vs.111).aspx
        mutable newData = data;
        set newData[pos] = datum;
        
        return ResultStack(size, pos + 1, newData);
    }

    /// # Summary
    /// Retrieves the topmost element of a <xref:microsoft.quantum.canon.resultstack>.
    ///
    /// # Input
    /// ## stack
    /// The stack to be inspected.
    ///
    /// # Output
    /// The value stored at the top of `stack`.
    function StackPeek(stack : ResultStack) : Result {
        let (size, pos, data) = stack;
        if (pos == 0) {
            fail "Cannot peek at an empty stack.";
        }
        return data[pos - 1];
    }

    /// # Summary
    /// Creates a new empty <xref:microsoft.quantum.canon.resultstack> with given capacity.
    ///
    /// # Input
    /// ## size
    /// The capacity of the new stack.
    ///
    /// # Output
    /// A new `ResultStack` that has capacity `size` and length 0.
    function StackNew(size : Int) : ResultStack {
        return ResultStack(size, 0, new Result[size]);
    }

}
