// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Samples.VisualDebugger
{
    /// <summary>
    /// The hub recives receives events and commands from the web browser client and sends them to the visual debugger
    /// server.
    /// </summary>
    internal class VisualDebuggerHub : Hub
    {
        private readonly VisualDebugger debugger;

        public VisualDebuggerHub(VisualDebugger debugger)
        {
            this.debugger = debugger;
        }

        public override async Task OnConnectedAsync()
        {
            await debugger.ReplayHistory(Clients.Caller);
            await base.OnConnectedAsync();
        }

        public bool Advance() => debugger.Advance();
    }
}
