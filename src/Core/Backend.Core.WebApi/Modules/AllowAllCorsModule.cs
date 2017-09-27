using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;

namespace GoldenEye.Backend.Core.WebApi.Modules
{
    public class AllowAllCorsModule : WebApiModuleBase
    {
        public AllowAllCorsModule(IConfiguration configuration) : base(configuration)
        {
        }
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

        public override void OnStartup(IApplicationBuilder app, IHostingEnvironment env)
        {
            app.UseCors("AllowAllCorsPolicy");
        }
    }
}
