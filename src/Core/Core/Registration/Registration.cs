using FluentValidation;
using GoldenEye.Core.Repositories;
using GoldenEye.Core.Extensions.DependencyInjection;
using GoldenEye.Core.Objects.General;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Core.Registration
{
    public static class Registration
    {
        public static IServiceCollection AddInMemoryRepository<TEntity>(this IServiceCollection services,
            ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TEntity : class, IHaveId
        {
            services.Add(sp => new InMemoryRepository<TEntity>(), serviceLifetime);
            services.Add<IRepository<TEntity>>(sp => sp.GetService<InMemoryRepository<TEntity>>(), serviceLifetime);
            services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetService<InMemoryRepository<TEntity>>(),
                serviceLifetime);
            return services;
        }

        public static IServiceCollection AddInMemoryReadonlyRepository<TDataContext, TEntity>(
            this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TEntity : class, IHaveId
        {
            services.Add(sp => new InMemoryReadonlyRepository<TEntity>(), serviceLifetime);
            services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetService<InMemoryReadonlyRepository<TEntity>>(),
                serviceLifetime);
            return services;
        }

        public static IServiceCollection AddAllValidators(this IServiceCollection services,
            ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        {
            services.Scan(scan => scan
                .FromApplicationDependencies()
                .AddClasses(classes => classes.Where(t => !t.IsGenericType).AssignableTo(typeof(IValidator<>)))
                .AsImplementedInterfaces()
                .WithLifetime(serviceLifetime));

            return services;
        }
    }
}
