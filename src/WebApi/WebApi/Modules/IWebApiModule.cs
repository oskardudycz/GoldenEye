using GoldenEye.Shared.Core.Modules;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;

namespace GoldenEye.Backend.Core.WebApi.Modules
{
    public interface IWebApiModule: IModule
    {
        void Use(IApplicationBuilder app, IWebHostEnvironment env);
    }
}
