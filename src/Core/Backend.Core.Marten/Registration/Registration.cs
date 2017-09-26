using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Marten.Context;
using GoldenEye.Backend.Core.Marten.Events.Storage;
using GoldenEye.Backend.Core.Registration;
using Marten;
using Microsoft.Extensions.DependencyInjection;
using System;

namespace GoldenEye.Backend.Core.Marten.Registration
{
    public static class Registration
    {
        public static void AddMartenContext(this IServiceCollection services, string moduleName, Func<IServiceProvider, string> getConnectionString, Action<StoreOptions> setAdditionalOptions = null)
        {
            services.AddSingleton(sp =>
            {
                return CreateDocumentStore(moduleName, getConnectionString(sp), setAdditionalOptions);
            });

            services.AddScoped(sp =>
            {
                var store = sp.GetService<DocumentStore>();
                return CreateDocumentSession(store);
            });
        }

        public static void AddMartenEventStorePipeline(this IServiceCollection services)
        {
            services.AddEventStorePipeline<MartenEventStore>();
        }
        
        public static void AddMartenDocumentDataContext<TDbContext>(this IServiceCollection services)
        {
            services.AddScoped(sp => new MartenDocumentDataContext(sp.GetService<IDocumentSession>()));
        }
        public static void AddMartenDocumentCRUDRepository<TDbContext, TEntity>(this IServiceCollection services)
            where TEntity : class, IEntity
        {
            services.AddCRUDRepository<MartenDocumentDataContext, TEntity>();
        }
        public static void AddMartenDocumentReadonlyRepository<TDbContext, TEntity>(this IServiceCollection services)
            where TEntity : class, IEntity
        {
            services.AddReadonlyRepository<MartenDocumentDataContext, TEntity>();
        }

        public static DocumentStore CreateDocumentStore(string moduleName, string connectionString, Action<StoreOptions> setAdditionalOptions = null)
        {
            var store = DocumentStore.For(_ =>
            {
                _.Connection(connectionString);
                _.DatabaseSchemaName = _.Events.DatabaseSchemaName = moduleName.ToLower();
                _.AutoCreateSchemaObjects = AutoCreate.CreateOrUpdate;
                _.DdlRules.TableCreation = CreationStyle.CreateIfNotExists;

                setAdditionalOptions?.Invoke(_);
            });

            return store;
        }

        public static IDocumentSession CreateDocumentSession(DocumentStore store)
        {
            var session = store.OpenSession();
            return session;
        }
    }
}
