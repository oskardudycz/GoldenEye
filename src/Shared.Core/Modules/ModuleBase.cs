using AutoMapper.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Shared.Core.Modules
{
    public abstract class ModuleBase : IModule
    {
        protected readonly IConfiguration configuration;

        protected ModuleBase(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public virtual void Configure(IServiceCollection services)
        {
        }

        public virtual void OnStartup()
        {

        }
    }
}