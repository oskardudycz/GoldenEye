using System;
using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.Marten.Context;
using GoldenEye.Backend.Core.Marten.Events.Storage;
using GoldenEye.Backend.Core.Registration;
using GoldenEye.Shared.Core.Extensions.Basic;
using GoldenEye.Shared.Core.Extensions.DependencyInjection;
using GoldenEye.Shared.Core.Objects.General;
using Marten;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Core.Marten.Registration
{
    public static class Registration
    {
        public static void AddMartenContext(this IServiceCollection services, Func<IServiceProvider, string> getConnectionString, Action<StoreOptions> setAdditionalOptions = null, string schemaName = null, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        {
            services.AddScoped(sp =>
            {
                return CreateDocumentStore(getConnectionString(sp), setAdditionalOptions, schemaName);
            });

            services.Add(sp =>
            {
                var store = sp.GetService<DocumentStore>();
                return CreateDocumentSession(store);
            }, serviceLifetime);

            services.AddEventStore<MartenEventStore>(serviceLifetime);
        }

        public static void AddMartenDocumentDataContext(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        {
            services.Add(sp => new MartenDocumentDataContext(sp.GetService<IDocumentSession>()), serviceLifetime);
        }

        public static void AddMartenDocumentCRUDRepository<TEntity>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TEntity : class, IHasId
        {
            services.AddCRUDRepository<MartenDocumentDataContext, TEntity>(serviceLifetime);
        }

        public static void AddMartenDocumentReadonlyRepository<TEntity>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TEntity : class, IHasId
        {
            services.AddReadonlyRepository<MartenDocumentDataContext, TEntity>(serviceLifetime);
        }

        public static DocumentStore CreateDocumentStore(string connectionString, Action<StoreOptions> setAdditionalOptions = null, string moduleName = null)
        {
            var store = DocumentStore.For(_ =>
            {
                _.Connection(connectionString);
                _.DatabaseSchemaName = _.Events.DatabaseSchemaName = moduleName.ToLower();
                _.AutoCreateSchemaObjects = AutoCreate.CreateOrUpdate;
                _.DdlRules.TableCreation = CreationStyle.CreateIfNotExists;

                if (!moduleName.IsNullOrEmpty())
                    _.DatabaseSchemaName = _.Events.DatabaseSchemaName = moduleName.ToLower();

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