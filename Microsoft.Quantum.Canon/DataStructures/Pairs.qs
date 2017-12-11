// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Given a pair, returns its first element.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the pair's first member.
    /// ## 'U
    /// The type of the pair's second member.
    ///
    /// # Input
    /// ## pair
    /// A tuple with two elements.
    ///
    /// # Output
    /// The first element of `pair`.
    function Fst<'T, 'U>(pair : ('T, 'U)) : 'T {
        let (fst, snd) = pair;
        return fst;
    }

    /// # Summary
    /// Given a pair, returns its second element.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the pair's first member.
    /// ## 'U
    /// The type of the pair's second member.
    ///
    /// # Input
    /// ## pair
    /// A tuple with two elements.
    ///
    /// # Output
    /// The second element of `pair`.
    function Snd<'T, 'U>(pair : ('T, 'U)) : 'U {
        let (fst, snd) = pair;
        return snd;
    }

}
