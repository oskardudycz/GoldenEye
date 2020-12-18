using System;
using GoldenEye.Events;
using GoldenEye.Extensions.Basic;
using GoldenEye.Extensions.DependencyInjection;
using GoldenEye.Marten.Repositories;
using GoldenEye.Marten.Events.Storage;
using GoldenEye.Objects.General;
using GoldenEye.Registration;
using GoldenEye.Repositories;
using Marten;
using Marten.Services;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Marten.Registration
{
    public static class Registration
    {
        public static void AddMarten(this IServiceCollection services,
            Func<IServiceProvider, string> getConnectionString, Action<StoreOptions> setAdditionalOptions = null,
            string schemaName = null, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        {
            services.AddScoped(sp => CreateDocumentStore(getConnectionString(sp), setAdditionalOptions, schemaName));

            services.Add(sp =>
            {
                var store = sp.GetService<DocumentStore>();
                return CreateDocumentSession(store);
            }, serviceLifetime);

            services.AddEventStore<MartenEventStore>(serviceLifetime);
        }

        public static void AddMartenDocumentRepository<TEntity>(this IServiceCollection services,
            ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TEntity : class, IHaveId
        {
            services.Add(sp => new MartenDocumentRepository<TEntity>(sp.GetService<IDocumentSession>()),
                serviceLifetime);

            services.Add<IRepository<TEntity>>(sp => sp.GetService<MartenDocumentRepository<TEntity>>(),
                serviceLifetime);
            services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetService<MartenDocumentRepository<TEntity>>(),
                serviceLifetime);
        }

        public static void AddMartenEventSourcedRepository<TEntity>(this IServiceCollection services,
            ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TEntity : class, IEventSource, new()
        {
            services.Add(sp => new MartenEventSourcedRepository<TEntity>(sp.GetService<IDocumentSession>(), sp.GetService<MartenEventStore>()),
                serviceLifetime);

            services.Add<IRepository<TEntity>>(sp => sp.GetService<MartenEventSourcedRepository<TEntity>>(),
                serviceLifetime);
            services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetService<MartenEventSourcedRepository<TEntity>>(),
                serviceLifetime);
        }

        public static void AddMartenDocumentReadonlyRepository<TEntity>(this IServiceCollection services,
            ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TEntity : class, IHaveId
        {
            services.Add(sp => new MartenDocumentRepository<TEntity>(sp.GetService<IDocumentSession>()),
                serviceLifetime);

            services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetService<MartenDocumentRepository<TEntity>>(),
                serviceLifetime);
        }

        public static DocumentStore CreateDocumentStore(string connectionString,
            Action<StoreOptions> setAdditionalOptions = null, string moduleName = null)
        {
            var store = DocumentStore.For(_ =>
            {
                _.Connection(connectionString);
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
            var session = store.OpenSession(SessionOptions.ForCurrentTransaction());
            return session;
        }
    }
}
