using GoldenEye.Shared.Core.Modules;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;

namespace GoldenEye.Backend.Core.WebApi.Modules
{
    interface IWebApiModule : IModule
    {
        void Use(IApplicationBuilder app, IHostingEnvironment env);
    }
}
