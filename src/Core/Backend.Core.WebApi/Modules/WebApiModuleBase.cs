using AutoMapper.Configuration;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;

namespace GoldenEye.Backend.Core.WebApi.Modules
{
    public class WebApiModuleBase : Shared.Core.Modules.ModuleBase, IWebApiModule
    {
        protected WebApiModuleBase(IConfiguration configuration) : base(configuration)
        {
        }

        public virtual void OnStartup(IApplicationBuilder app, IHostingEnvironment env)
        {
        }
    }
}
