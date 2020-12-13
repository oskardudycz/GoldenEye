using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Core.Modules
{
    public interface IModule
    {
        void Configure(IServiceCollection services);

        void Use();
    }
}
