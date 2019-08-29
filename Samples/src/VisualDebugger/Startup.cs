using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;

namespace Microsoft.Quantum.Samples.VisualDebugger
{
    internal class Startup
    {
        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddSignalR();
            services.AddMvc();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env) =>
            app
                .UseDefaultFiles()
                .UseStaticFiles()
                .UseDeveloperExceptionPage()
                .UseMvc()
                .UseSignalR(routes => routes.MapHub<VisualHub>("/events"));
    }
}
