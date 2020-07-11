// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Teleportation {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation RunProgram () : Unit {
     
        for (idxRun in 1 .. 8) {
            let sent = Random([0.5, 0.5]) == 0;
            let received = TeleportClassicalMessage(sent);
            Message($"Round {idxRun}: Sent {sent}, got {received}.");
            Message(sent == received ? "Teleportation successful!" | "");
        }
        
    }
}
