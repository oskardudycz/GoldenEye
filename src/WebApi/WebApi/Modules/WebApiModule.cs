using GoldenEye.Core.Modules;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;

namespace GoldenEye.WebApi.Modules
{
    public abstract class WebApiModule: Module, IWebApiModule
    {
        public virtual void Use(IApplicationBuilder app, IWebHostEnvironment env)
        {
            base.Use();
        }
    }
}
