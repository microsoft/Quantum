// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace Microsoft.Quantum.Samples.StateVisualizer
{
    /// <summary>
    /// Configures the ASP.NET Core web host. This class is used when the web host is created in
    /// <see cref="StateVisualizer"/>.
    /// </summary>
    internal class Startup
    {
        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddSignalR();
            services.AddMvc();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostApplicationLifetime lifetime, StateVisualizer visualizer)
        {
            app
                .UseDefaultFiles()
                .UseStaticFiles()
                .UseDeveloperExceptionPage()
                .UseRouting()
                .UseEndpoints(endpoints =>
                {
                    endpoints.MapControllers();
                    endpoints.MapHub<StateVisualizerHub>("/events");
                });
        }
    }
}
