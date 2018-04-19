using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;

namespace GoldenEye.Backend.Core.WebApi.Modules
{
    public abstract class WebApiModule : Shared.Core.Modules.Module, IWebApiModule
    {
        public virtual void OnStartup(IApplicationBuilder app, IHostingEnvironment env)
        {
            base.Use();
        }
    }
}