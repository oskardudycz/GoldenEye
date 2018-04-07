using FluentValidation;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.DependencyInjection;
using GoldenEye.Shared.Core.Objects.General;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Core.Registration
{
    public static class Registration
    {
        public static IServiceCollection AddDataContext<TDataContext>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Scoped)
            where TDataContext : class, IDataContext
        {
            services.Add<TDataContext>(serviceLifetime);
            return services;
        }

        public static IServiceCollection AddCRUDRepository<TDataContext, TEntity>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TDataContext : IDataContext
            where TEntity : class, IHasId
        {
            services.Add(sp => new CRUDRepository<TEntity>(sp.GetService<TDataContext>()), serviceLifetime);
            services.Add<IRepository<TEntity>>(sp => sp.GetService<CRUDRepository<TEntity>>(), serviceLifetime);
            services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetService<CRUDRepository<TEntity>>(), serviceLifetime);
            return services;
        }

        public static IServiceCollection AddReadonlyRepository<TDataContext, TEntity>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TDataContext : IDataContext
            where TEntity : class, IHasId
        {
            services.Add(sp => new ReadonlyRepository<TEntity>(sp.GetService<TDataContext>()), serviceLifetime);
            services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetService<ReadonlyRepository<TEntity>>(), serviceLifetime);
            return services;
        }

        public static IServiceCollection AddAllValidators(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
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