using GoldenEye.Shared.Core.Modules;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Core.WebApi.Modules
{
    public static class Registration
    {
        public static void UseModules(this IApplicationBuilder app, IHostingEnvironment env)
        {
            var modules = app.ApplicationServices.GetServices<IModule>();

            foreach (var module in modules)
            {
                if (module is IWebApiModule webApiModule)
                {
                    webApiModule.OnStartup(app, env);
                }
                else
                {
                    module.Use();
                }
            }
        }
    }
}