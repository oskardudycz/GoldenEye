using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.WebApi.Modules;
using GoldenEye.Backend.Core.WebApi.Registration;
using GoldenEye.Shared.Core.Configuration;
using GoldenEye.Shared.Core.Mappings;
using GoldenEye.Shared.Core.Modules;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Newtonsoft.Json.Converters;

namespace Backend.DDD.WebApi.Sample
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
            services.AddControllers()
                .AddNewtonsoftJson(opt => opt.SerializerSettings.Converters.Add(new StringEnumConverter()));
            services.AddDDD()
                .AddAllDDDHandlers()
                .AddAutoMapperForAllDependencies()
                .AddConfiguration(Configuration)
                .AddAllApplicationModules()
                .AddModule<AllowAllCorsModule>()
                .AddModule<SwaggerModule>()
                .AddCors(options =>
                {
                    options.AddPolicy("CorsPolicy",
                        builder =>
                        builder.AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader()
                        .AllowCredentials()
                    );
                });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseRouting()
                .UseAuthorization()
                .UseEndpoints(endpoints =>
                {
                    endpoints.MapControllers();
                })
                .UseExceptionHandlingMiddleware()
                .UseModules(env)
                .UseCors("CorsPolicy");
        }
    }
}
