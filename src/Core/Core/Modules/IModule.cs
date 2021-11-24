using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Modules;

public interface IModule
{
    void Configure(IServiceCollection services);

    void Use();
}