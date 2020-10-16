// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Samples.StateVisualizer
{
    /// <summary>
    /// The hub receives events and commands from the web browser client and sends them to the state visualizer
    /// server.
    /// </summary>
    internal class StateVisualizerHub : Hub
    {
        private readonly StateVisualizer visualizer;

        public StateVisualizerHub(StateVisualizer visualizer)
        {
            this.visualizer = visualizer;
        }

        public override async Task OnConnectedAsync()
        {
            visualizer.GetExecutionPath();
            await base.OnConnectedAsync();
        }
    }
}
