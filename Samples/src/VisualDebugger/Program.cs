using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Quantum.Simulation.Simulators;

namespace vis_sim
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var debugger = new VisualDebugger(new QuantumSimulator());
            debugger.Run(HelloQ.Run).Wait();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>();
    }
}
