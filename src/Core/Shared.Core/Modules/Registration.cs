using System;
using GoldenEye.Shared.Core.Extensions.DependencyInjection;
using GoldenEye.Shared.Core.Modules.Attributes;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Shared.Core.Modules
{
    public static class Registration
    {
        public static IServiceCollection AddAllModules(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Singleton)
        {
            services.Scan(scan => scan
                .FromApplicationDependencies()
                .AddClasses(classes => classes.AssignableTo<IModule>().WithoutAttribute<InternalModuleAttribute>())
                    .AsSelfWithInterfaces()
                    .WithLifetime(serviceLifetime)
                 );

            return services;
        }

        public static void AddModule<TModule>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Singleton) where TModule : class, IModule
        {
            services.Add<TModule, TModule>(serviceLifetime);
            services.Add<IModule, TModule>(sp => sp.GetService<TModule>());
            services.BuildServiceProvider().GetService<TModule>().Configure(services);
        }

        public static void UseModules(this IServiceProvider serviceProvider)
        {
            var modules = serviceProvider.GetServices<IModule>();

            foreach (var module in modules)
            {
                module.Use();
            }
        }
    }
}