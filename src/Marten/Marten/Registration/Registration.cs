using System;
using System.Threading;
using GoldenEye.Aggregates;
using GoldenEye.Events.Aggregate;
using GoldenEye.Extensions.Basic;
using GoldenEye.Extensions.DependencyInjection;
using GoldenEye.Marten.Repositories;
using GoldenEye.Marten.Events.Storage;
using GoldenEye.Objects.General;
using GoldenEye.Registration;
using GoldenEye.Repositories;
using GoldenEye.Utils.Threading;
using Marten;
using Marten.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Weasel.Core;
using Weasel.Postgresql;

namespace GoldenEye.Marten.Registration;

public static class Registration
{
    private const string DefaultConfigKey = "Marten";

    public static IServiceCollection AddMarten(
        this IServiceCollection services,
        Func<IServiceProvider, string> getConnectionString,
        Action<StoreOptions> setAdditionalOptions = null,
        string schemaName = null,
        ServiceLifetime serviceLifetime = ServiceLifetime.Transient
    )
    {
        services.AddScoped(sp => CreateDocumentStore(getConnectionString(sp), setAdditionalOptions, schemaName));

        services.Add(sp =>
        {
            var store = sp.GetService<DocumentStore>();
            return CreateDocumentSession(store);
        }, serviceLifetime);

        services.AddEventStore<MartenEventStore>(serviceLifetime);
        return services;
    }

    public static IServiceCollection AddMarten(
        this IServiceCollection services,
        IConfiguration config,
        Action<StoreOptions> configureOptions = null,
        string configKey = DefaultConfigKey,
        ServiceLifetime serviceLifetime = ServiceLifetime.Transient
    )
    {
        var martenConfig = config.GetSection(configKey).Get<MartenConfig>();

        var documentStore = services
            .AddMarten(options =>
            {
                SetStoreOptions(options, martenConfig, configureOptions);
            })
            .InitializeStore();

        SetupSchema(documentStore, martenConfig, 1);

        services.AddEventStore<MartenEventStore>(serviceLifetime);

        return services;
    }

    private static void SetupSchema(IDocumentStore documentStore, MartenConfig martenConfig, int retryLeft = 1)
    {
        try
        {
            if (martenConfig.ShouldRecreateDatabase)
                documentStore.Advanced.Clean.CompletelyRemoveAll();

            using (NoSynchronizationContextScope.Enter())
            {
                documentStore.Schema.ApplyAllConfiguredChangesToDatabaseAsync().Wait();
            }
        }
        catch(Exception ex)
        {
            Console.WriteLine(ex);
            if (retryLeft == 0) throw;

            Thread.Sleep(1000);
            SetupSchema(documentStore, martenConfig, --retryLeft);
        }
    }

    private static void SetStoreOptions(StoreOptions options, MartenConfig config,
        Action<StoreOptions> configureOptions = null)
    {
        options.Connection(config.ConnectionString);
        options.AutoCreateSchemaObjects = AutoCreate.CreateOrUpdate;

        var schemaName = Environment.GetEnvironmentVariable("SchemaName");
        options.Events.DatabaseSchemaName = schemaName ?? config.WriteModelSchema;
        options.DatabaseSchemaName = schemaName ?? config.ReadModelSchema;

        options.UseDefaultSerialization(nonPublicMembersStorage: NonPublicMembersStorage.NonPublicSetters,
            enumStorage: EnumStorage.AsString);
        options.Projections.AsyncMode = config.DaemonMode;

        configureOptions?.Invoke(options);
    }

    public static IServiceCollection AddMartenDocumentRepository<TEntity>(this IServiceCollection services,
        ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        where TEntity : class, IHaveId
    {
        services.Add(sp => new MartenDocumentRepository<TEntity>(sp.GetService<IDocumentSession>(), sp.GetService<IAggregateEventsPublisher>()),
            serviceLifetime);

        services.Add<IRepository<TEntity>>(sp => sp.GetService<MartenDocumentRepository<TEntity>>(),
            serviceLifetime);
        services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetService<MartenDocumentRepository<TEntity>>(),
            serviceLifetime);
        return services;
    }

    public static IServiceCollection AddMartenEventSourcedRepository<TEntity>(this IServiceCollection services,
        ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        where TEntity : class, IAggregate, new()
    {
        services.Add(sp => new MartenEventSourcedRepository<TEntity>(sp.GetService<IDocumentSession>(), sp.GetService<MartenEventStore>(), sp.GetService<IAggregateEventsPublisher>()),
            serviceLifetime);

        services.Add<IRepository<TEntity>>(sp => sp.GetService<MartenEventSourcedRepository<TEntity>>(),
            serviceLifetime);
        services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetService<MartenEventSourcedRepository<TEntity>>(),
            serviceLifetime);
        return services;
    }

    public static IServiceCollection AddMartenDocumentReadonlyRepository<TEntity>(this IServiceCollection services,
        ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        where TEntity : class, IHaveId
    {
        services.Add(sp => new MartenDocumentRepository<TEntity>(sp.GetService<IDocumentSession>(), sp.GetService<IAggregateEventsPublisher>()),
            serviceLifetime);

        services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetService<MartenDocumentRepository<TEntity>>(),
            serviceLifetime);
        return services;
    }

    public static DocumentStore CreateDocumentStore(string connectionString,
        Action<StoreOptions> setAdditionalOptions = null, string moduleName = null)
    {
        var store = DocumentStore.For(_ =>
        {
            _.Connection(connectionString);
            _.AutoCreateSchemaObjects = AutoCreate.CreateOrUpdate;

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
