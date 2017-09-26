using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Repositories;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Core.Registration
{
    public static class Registration
    {
        public static void AddDataContext<TDataContext>(this IServiceCollection services)
            where TDataContext: class, IDataContext
        {
            services.AddScoped<TDataContext>();
        }
        public static void AddCRUDRepository<TDataContext, TEntity>(this IServiceCollection services)
            where TDataContext : IDataContext
            where TEntity : class, IEntity
        {
            services.AddScoped(sp => new CRUDRepository<TEntity>(sp.GetService<TDataContext>()));
            services.AddScoped<IRepository<TEntity>>(sp => sp.GetService<CRUDRepository<TEntity>>());
            services.AddScoped<IReadonlyRepository<TEntity>>(sp => sp.GetService<CRUDRepository<TEntity>>());
        }
        
        public static void AddReadonlyRepository<TDataContext, TEntity>(this IServiceCollection services)
            where TDataContext : IDataContext
            where TEntity : class, IEntity
        {
            services.AddScoped(sp => new ReadonlyRepository<TEntity>(sp.GetService<TDataContext>()));
            services.AddScoped<IReadonlyRepository<TEntity>>(sp => sp.GetService<ReadonlyRepository<TEntity>>());
        }
    }
}
