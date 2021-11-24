using GoldenEye.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Configuration;

public static class Registration
{
    public static IServiceCollection AddConfiguration(this IServiceCollection services,
        IConfiguration configuration, ServiceLifetime serviceLifetime = ServiceLifetime.Singleton)
    {
        return services.Add(sp => configuration, serviceLifetime);
    }
}