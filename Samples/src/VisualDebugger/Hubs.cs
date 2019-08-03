using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace vis_sim
{
    public class VisualizationHub : Hub
    {
        private readonly VisualDebugger debugger;

        public VisualizationHub(VisualDebugger debugger)
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
