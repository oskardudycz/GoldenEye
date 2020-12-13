using GoldenEye.Shared.Core.Modules;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Core.WebApi.Modules
{
    public static class Registration
    {
        public static IApplicationBuilder UseApplicationModules(this IApplicationBuilder app, IWebHostEnvironment env)
        {
            var modules = app.ApplicationServices.GetServices<IModule>();

            foreach (var module in modules)
                if (module is IWebApiModule webApiModule)
                    webApiModule.Use(app, env);
                else
                    module.Use();

            return app;
        }
    }
}
