using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Core.WebApi.Modules
{
    public class AllowAllCorsModule : WebApiModule
    {
        public override void Configure(IServiceCollection services)
        {
            services.AddCors(options =>
            {
                options.AddPolicy("AllowAllCorsPolicy",
                    builder =>
                    builder.AllowAnyOrigin()
                    .AllowAnyMethod()
                    .AllowAnyHeader()
                    .AllowCredentials()
                );
            });
        }

        public override void Use(IApplicationBuilder app, IHostingEnvironment env)
        {
            app.UseCors("AllowAllCorsPolicy");
        }
    }
}