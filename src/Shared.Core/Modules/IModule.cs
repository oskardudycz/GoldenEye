using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Shared.Core.Modules
{
    public interface IModule
    {
        void Configure(IServiceCollection services);
    }
}
