using System;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Registration;
using GoldenEye.Shared.Core.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Core.EntityFramework.Registration
{
    public static class Registration
    {
        public static void AddEFDataContext<TDbContext>(this IServiceCollection services, Action<IServiceProvider, DbContextOptionsBuilder> optionsAction, ServiceLifetime serviceLifetime = ServiceLifetime.Scoped)
            where TDbContext : DbContext
        {
            services.AddDbContext<TDbContext>(optionsAction, serviceLifetime);
            services.Add(sp => new EFDataContext<TDbContext>(sp.GetService<TDbContext>()), serviceLifetime);
        }

        public static void AddEFCRUDRepository<TDbContext, TEntity>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TDbContext : DbContext
            where TEntity : class, IEntity
        {
            services.AddCRUDRepository<EFDataContext<TDbContext>, TEntity>(serviceLifetime);
        }

        public static void AddEFReadonlyRepository<TDbContext, TEntity>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TDbContext : DbContext
            where TEntity : class, IEntity
        {
            services.AddReadonlyRepository<EFDataContext<TDbContext>, TEntity>(serviceLifetime);
        }
    }
}