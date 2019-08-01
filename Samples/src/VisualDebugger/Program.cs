using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;

namespace vis_sim
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var sim = new VisualizationSimulator();
            sim.Run(HelloQ.Run).Wait();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>();
    }
}
