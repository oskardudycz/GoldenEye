using FluentValidation;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Objects.General;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Core.Registration
{
    public static class Registration
    {
        public static IServiceCollection AddDataContext<TDataContext>(this IServiceCollection services)
            where TDataContext : class, IDataContext
        {
            services.AddScoped<TDataContext>();
            return services;
        }

        public static IServiceCollection AddCRUDRepository<TDataContext, TEntity>(this IServiceCollection services)
            where TDataContext : IDataContext
            where TEntity : class, IHasId
        {
            services.AddScoped(sp => new CRUDRepository<TEntity>(sp.GetService<TDataContext>()));
            services.AddScoped<IRepository<TEntity>>(sp => sp.GetService<CRUDRepository<TEntity>>());
            services.AddScoped<IReadonlyRepository<TEntity>>(sp => sp.GetService<CRUDRepository<TEntity>>());
            return services;
        }

        public static IServiceCollection AddReadonlyRepository<TDataContext, TEntity>(this IServiceCollection services)
            where TDataContext : IDataContext
            where TEntity : class, IHasId
        {
            services.AddScoped(sp => new ReadonlyRepository<TEntity>(sp.GetService<TDataContext>()));
            services.AddScoped<IReadonlyRepository<TEntity>>(sp => sp.GetService<ReadonlyRepository<TEntity>>());
            return services;
        }

        public static IServiceCollection AddAllValidators(this IServiceCollection services)
        {
            services.Scan(scan => scan
                .FromApplicationDependencies()
                    .AddClasses(classes => classes.AssignableTo(typeof(IValidator<>)))
                        .AsImplementedInterfaces()
                        .WithTransientLifetime());

            return services;
        }
    }
}