// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Teleportation {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random; 

    @EntryPoint()
    operation RunProgram () : Unit {
        for idxRun in 1 .. 8 {
            let sent = DrawRandomBool(0.5);
            let received = TeleportClassicalMessage(sent);
            Message($"Round {idxRun}: Sent {sent}, got {received}.");
            Message(sent == received ? "Teleportation successful!" | "");
        }
    }
}
