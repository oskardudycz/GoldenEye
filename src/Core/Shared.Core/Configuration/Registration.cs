using GoldenEye.Shared.Core.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Shared.Core.Configuration
{
    public static class Registration
    {
        public static void AddConfiguration<TConfiguation>(this IServiceCollection services, TConfiguation configuration, ServiceLifetime serviceLifetime = ServiceLifetime.Singleton)
            where TConfiguation : class, IConfiguration
        {
            services.Add<IConfiguration, TConfiguation>(serviceLifetime);
            services.Add<IConfiguration, TConfiguation>(sp => sp.GetService<TConfiguation>(), serviceLifetime);
        }
    }
}