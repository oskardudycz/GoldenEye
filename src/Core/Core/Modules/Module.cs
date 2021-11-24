using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Modules;

public abstract class Module: IModule
{
    public virtual void Configure(IServiceCollection services)
    {
    }

    public virtual void Use()
    {
    }
}