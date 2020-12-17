using GoldenEye.Core.Modules;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;

namespace GoldenEye.WebApi.Modules
{
    public interface IWebApiModule: IModule
    {
        void Use(IApplicationBuilder app, IWebHostEnvironment env);
    }
}
