using System;
using GoldenEye.Core.Extensions.Collections;
using GoldenEye.Core.Extensions.DependencyInjection;
using GoldenEye.Core.Modules.Attributes;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Core.Modules
{
    public static class Registration
    {
        public static IServiceCollection AddAllApplicationModules(this IServiceCollection services,
            ServiceLifetime serviceLifetime = ServiceLifetime.Singleton)
        {
            services.Scan(scan => scan
                .FromApplicationDependencies()
                .AddClasses(classes => classes.AssignableTo<IModule>().WithoutAttribute<InternalModuleAttribute>())
                .AsSelfWithInterfaces()
                .WithLifetime(serviceLifetime)
            );

            services.BuildServiceProvider().GetServices<IModule>().ForEach(module => module.Configure(services));

            return services;
        }

        public static IServiceCollection AddModule<TModule>(this IServiceCollection services,
            ServiceLifetime serviceLifetime = ServiceLifetime.Singleton) where TModule : class, IModule
        {
            services.Add<TModule, TModule>(serviceLifetime)
                .Add<IModule, TModule>(sp => sp.GetService<TModule>());

            services.BuildServiceProvider().GetService<TModule>().Configure(services);

            return services;
        }

        public static void UseModules(this IServiceProvider serviceProvider)
        {
            var modules = serviceProvider.GetServices<IModule>();

            foreach (var module in modules) module.Use();
        }
    }
}
