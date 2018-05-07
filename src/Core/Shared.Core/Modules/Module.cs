using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Shared.Core.Modules
{
    public abstract class Module : IModule
    {
        public virtual void Configure(IServiceCollection services)
        {
        }

        public virtual void Use()
        {
        }
    }
}