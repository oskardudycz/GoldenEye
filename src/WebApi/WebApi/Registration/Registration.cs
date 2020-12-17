using System;
using GoldenEye.WebApi.Modules;
using GoldenEye.Core.Configuration;
using GoldenEye.Core.Modules;
using GoldenEye.WebApi.Exceptions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json.Converters;
using Swashbuckle.AspNetCore.SwaggerGen;
using Swashbuckle.AspNetCore.SwaggerUI;

namespace GoldenEye.WebApi.Registration
{
    public static class Registration
    {
        public static IMvcBuilder AddWebApiWithDefaultConfig(
            this IServiceCollection services,
            IConfiguration configuration = null,
            Action<SwaggerGenOptions> setupSwagger = null,
            Action<MvcNewtonsoftJsonOptions> setupNewtonsoft = null)
        {
            if (configuration != null)
                services.AddConfiguration(configuration);

            return services
                .AddAllApplicationModules()
                .AddDefaultCorsSetup()
                .AddSwagger(setupSwagger)
                .AddWebApiWithNewtonsoft(setupNewtonsoft);
        }

        public static IServiceCollection AddSwagger(
            this IServiceCollection services,
            Action<SwaggerGenOptions> setupSwagger = null)
        {
            static void DefaultSwaggerSetup(SwaggerGenOptions opt)
            {
                opt.SwaggerDoc("v1", new OpenApiInfo {Title = "API", Version = "v1"});
            }

            return services
                .AddSwaggerGen(setupSwagger ?? DefaultSwaggerSetup);
        }

        public static IMvcBuilder AddWebApiWithNewtonsoft(
            this IServiceCollection services,
            Action<MvcNewtonsoftJsonOptions> setupNewtonsoft = null)
        {
            static void DefaultNewtonsoftSetup(MvcNewtonsoftJsonOptions opt)
            {
                opt.SerializerSettings.Converters.Add(new StringEnumConverter());
            }

            return services
                .AddControllers()
                .AddNewtonsoftJson(setupNewtonsoft ?? DefaultNewtonsoftSetup);
        }

        public static IServiceCollection AddDefaultCorsSetup(this IServiceCollection services)
        {
            return services.AddCors(options =>
            {
                options.AddDefaultPolicy(
                    builder =>
                        builder.AllowAnyOrigin()
                            .AllowAnyMethod()
                            .AllowAnyHeader()
                );
            });
        }

        public static IApplicationBuilder UseWebApi(this IApplicationBuilder app)
        {
            return app.UseRouting()
                .UseAuthorization()
                .UseCors()
                .UseEndpoints(endpoints =>
                {
                    endpoints.MapControllers();
                });
        }

        public static IApplicationBuilder UseWebApiWithDefaultConfig(
            this IApplicationBuilder app,
            IWebHostEnvironment env,
            Action<SwaggerUIOptions> setupSwaggerUI = null
        )
        {
            static void DefaultSwaggerSetup(SwaggerUIOptions opt)
            {
                opt.SwaggerEndpoint("/swagger/v1/swagger.json", "Meeting Management V1");
                opt.RoutePrefix = string.Empty;
            }

            return app
                .UseExceptionHandlingMiddleware()
                .UseWebApi()
                .UseSwagger()
                .UseSwaggerUI(setupSwaggerUI ?? DefaultSwaggerSetup)
                .UseApplicationModules(env);
        }

        public static IApplicationBuilder UseExceptionHandlingMiddleware(this IApplicationBuilder app)
        {
            app.UseMiddleware(typeof(ExceptionHandlingMiddleware));
            return app;
        }
    }
}
