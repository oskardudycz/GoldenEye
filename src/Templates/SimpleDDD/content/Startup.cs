using System;
using AutoMapper;
using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.WebApi.Modules;
using GoldenEye.Backend.Core.WebApi.Registration;
using GoldenEye.Shared.Core.Configuration;
using GoldenEye.Shared.Core.Modules;
using GoldenEye.WebApi.Template.SimpleDDD.Backend;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.WebApi.Template.SimpleDDD
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
            services.AddMvc();
            services.AddDDD();

            services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
            services.AddConfiguration(Configuration);

            services.AddModule<BackendModule>();
            services.AddModule<AllowAllCorsModule>();
            services.AddModule<SwaggerModule>();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseExceptionHandlingMiddleware();
            app.UseModules(env);

            app.UseMvc();
        }
    }
}