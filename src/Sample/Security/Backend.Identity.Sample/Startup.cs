using System.Reflection;
using GoldenEye.Backend.Core.WebApi;
using GoldenEye.Backend.Identity;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Backend.Identity.Sample
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            var migrationsAssembly = typeof(Startup).GetTypeInfo().Assembly.GetName().Name;
            services.AddMvcWithHttps();

            services.AddIdentityServerWithEFPersistedStorage(options =>
                {
                    options.UseNpgsql(Configuration.GetConnectionString("IdentityDatabase"), b => b.MigrationsAssembly(migrationsAssembly));
                });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseSampleIdentityData();

            app.UseStaticFiles();
            app.UseMvcWithDefaultRoute();

            app.UseIdentityServer();
        }
    }
}