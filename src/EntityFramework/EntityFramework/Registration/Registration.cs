using System;
using GoldenEye.Core.Entities;
using GoldenEye.Core.Entity;
using GoldenEye.EntityFramework.Migrations;
using GoldenEye.Core.Repositories;
using GoldenEye.Core.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace GoldenEye.EntityFramework.Registration
{
    public static class Registration
    {
        public static void AddEntityFramework(this IServiceCollection services)
        {
            services.TryAddScoped<IEntityFrameworkMigrationsRunner>();
        }

        public static void AddEntityFrameworkDbContext<TDbContext>(this IServiceCollection services,
            Action<IServiceProvider, DbContextOptionsBuilder> optionsAction,
            ServiceLifetime serviceLifetime = ServiceLifetime.Scoped)
            where TDbContext : DbContext
        {
            services.AddDbContext<TDbContext>(optionsAction, serviceLifetime);
            services.Add<IEntityFrameworkDbContextMigrationRunner<TDbContext>>(sp =>
                new EntityFrameworkDbContextMigrationRunner<TDbContext>(sp.GetService<TDbContext>()), serviceLifetime);
            services.Add<IEntityFrameworkDbContextMigrationRunner>(sp =>
                new EntityFrameworkDbContextMigrationRunner<TDbContext>(sp.GetService<TDbContext>()), serviceLifetime);
        }

        public static void AddEntityFrameworkRepository<TDbContext, TEntity>(this IServiceCollection services,
            ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TDbContext : DbContext
            where TEntity : class, IEntity
        {
            services.Add(sp => new EntityFrameworkRepository<TDbContext, TEntity>(sp.GetService<TDbContext>()),
                serviceLifetime);

            services.Add<IRepository<TEntity>>(sp => sp.GetService<EntityFrameworkRepository<TDbContext, TEntity>>(),
                serviceLifetime);
            services.Add<IReadonlyRepository<TEntity>>(
                sp => sp.GetService<EntityFrameworkRepository<TDbContext, TEntity>>(), serviceLifetime);
        }

        public static void AddEntityFrameworkReadonlyRepository<TDbContext, TEntity>(this IServiceCollection services,
            ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TDbContext : DbContext
            where TEntity : class, IEntity
        {
            services.Add(sp => new EntityFrameworkRepository<TDbContext, TEntity>(sp.GetService<TDbContext>()),
                serviceLifetime);

            services.Add<IReadonlyRepository<TEntity>>(
                sp => sp.GetService<EntityFrameworkRepository<TDbContext, TEntity>>(), serviceLifetime);
        }
    }
}
