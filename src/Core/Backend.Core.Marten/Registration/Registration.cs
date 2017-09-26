using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.Marten.Events.Storage;
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
