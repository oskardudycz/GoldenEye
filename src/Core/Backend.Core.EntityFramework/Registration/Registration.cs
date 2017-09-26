using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Registration;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using System;

namespace GoldenEye.Backend.Core.EntityFramework.Registration
{
    public static class Registration
    {
        public static void AddEFDataContext<TDbContext>(this IServiceCollection services, Action<IServiceProvider, DbContextOptionsBuilder> optionsAction)
            where TDbContext : DbContext
        {
            services.AddDbContext<TDbContext>(optionsAction, ServiceLifetime.Scoped);
            services.AddScoped(sp => new EFDataContext<TDbContext>(sp.GetService<TDbContext>()));
        }
        public static void AddEFCRUDRepository<TDbContext, TEntity>(this IServiceCollection services)
            where TDbContext : DbContext
            where TEntity : class, IEntity
        {
            services.AddCRUDRepository<EFDataContext<TDbContext>, TEntity>();
        }
        public static void AddEFReadonlyRepository<TDbContext, TEntity>(this IServiceCollection services)
            where TDbContext : DbContext
            where TEntity : class, IEntity
        {
            services.AddReadonlyRepository<EFDataContext<TDbContext>, TEntity>();
        }
    }
}
