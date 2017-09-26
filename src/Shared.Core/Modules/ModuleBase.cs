using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Shared.Core.Modules
{
    public abstract class ModuleBase : IModule
    {
        public virtual void Configure(IServiceCollection services)
        {
        }
    }
}