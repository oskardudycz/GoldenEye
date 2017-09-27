using GoldenEye.Shared.Core.Modules;
using System;
using System.Collections.Generic;
using System.Text;
using AutoMapper.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Swashbuckle.AspNetCore.Swagger;

namespace GoldenEye.Backend.Core.WebApi.Modules
{
    public class SwaggerModule : WebApiModuleBase
    {
        public SwaggerModule(IConfiguration configuration) : base(configuration)
        {
        }
        public override void Configure(IServiceCollection services)
        {
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new Info { Title = "API", Version = "v1" });
            });
        }

        public override void OnStartup(IApplicationBuilder app, IHostingEnvironment env)
        {
            app.UseSwagger();

            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "API V1");
            });
        }
    }
}
