using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace vis_sim
{
    public class VisualHub : Hub
    {
        private readonly VisualDebugger debugger;

        public VisualHub(VisualDebugger debugger)
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
