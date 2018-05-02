using AutoMapper;
using Backend;
using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.WebApi.Modules;
using GoldenEye.Backend.Core.WebApi.Registration;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.WebApi.SimpleDDD
{
    public class Startup
    {
        private readonly BackendModule backendModule;
        private readonly AllowAllCorsModule corsModule;
        private readonly SwaggerModule swaggerModule;

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
            backendModule = new BackendModule(Configuration);
            corsModule = new AllowAllCorsModule();
            swaggerModule = new SwaggerModule();
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddMvc();
            services.AddDDD();

            services.AddAutoMapper();

            backendModule.Configure(services);
            corsModule.Configure(services);
            services.AddCors(options =>
            {
                options.AddPolicy("CorsPolicy",
                    builder =>
                    builder.AllowAnyOrigin()
                    .AllowAnyMethod()
                    .AllowAnyHeader()
                    .AllowCredentials()
                );
            });
            swaggerModule.Configure(services);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseExceptionHandlingMiddleware();
            backendModule.Use();
            app.UseCors("CorsPolicy");
            corsModule.Use(app, env);
            swaggerModule.Use(app, env);

            app.UseMvc();
        }
    }
}