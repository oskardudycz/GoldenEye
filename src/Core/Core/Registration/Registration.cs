using FluentValidation;
using GoldenEye.Commands;
using GoldenEye.Events;
using GoldenEye.Events.Aggregate;
using GoldenEye.Events.External;
using GoldenEye.Events.Store;
using GoldenEye.Extensions.DependencyInjection;
using GoldenEye.IdsGenerator;
using GoldenEye.Objects.General;
using GoldenEye.Queries;
using GoldenEye.Repositories;
using GoldenEye.Validation;
using MediatR;
using MediatR.Pipeline;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace GoldenEye.Registration;

public static class Registration
{
    public static IServiceCollection AddInMemoryRepository<TEntity>(this IServiceCollection services,
        ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        where TEntity : class, IHaveId
    {
        services.Add(sp => new InMemoryRepository<TEntity>(), serviceLifetime);
        services.Add<IRepository<TEntity>>(sp => sp.GetRequiredService<InMemoryRepository<TEntity>>(), serviceLifetime);
        services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetRequiredService<InMemoryRepository<TEntity>>(),
            serviceLifetime);
        return services;
    }

    public static IServiceCollection AddInMemoryReadonlyRepository<TDataContext, TEntity>(
        this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        where TEntity : class, IHaveId
    {
        services.Add(sp => new InMemoryReadonlyRepository<TEntity>(), serviceLifetime);
        services.Add<IReadonlyRepository<TEntity>>(sp => sp.GetRequiredService<InMemoryReadonlyRepository<TEntity>>(),
            serviceLifetime);
        return services;
    }

    public static IServiceCollection AddAllValidators(this IServiceCollection services,
        ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
    {
        services.Scan(scan => scan
            .FromApplicationDependencies()
            .AddClasses(classes => classes.Where(t => !t.IsGenericType).AssignableTo(typeof(IValidator<>)))
            .AsImplementedInterfaces()
            .WithLifetime(serviceLifetime));

        return services;
    }

    public static IServiceCollection AddDDD(this IServiceCollection services,
        ServiceLifetime withLifetime = ServiceLifetime.Transient)
    {
        services.AddScoped<IMediator, Mediator>()
            .Add<ServiceFactory>(sp => sp.GetRequiredService, withLifetime)
            .Add(typeof(IPipelineBehavior<,>), typeof(RequestPreProcessorBehavior<,>), withLifetime)
            .Add<ICommandBus, CommandBus>(withLifetime)
            .Add<IQueryBus, QueryBus>(withLifetime)
            .Add<IEventBus, EventBus>(withLifetime)
            .Add<IAggregateEventsPublisher, AggregateEventsPublisher>(withLifetime);

        services.TryAddScoped<IIdGenerator, NulloIdGenerator>();
        services.TryAddScoped<IExternalEventProducer, NulloExternalEventProducer>();
        services.TryAddScoped<IExternalCommandBus, ExternalCommandBus>();

        return services;
    }

    public static IServiceCollection AddEventStore<TEventStore>(this IServiceCollection services,
        ServiceLifetime withLifetime = ServiceLifetime.Transient)
        where TEventStore : class, IEventStore
    {
        return services.Add<TEventStore, TEventStore>(withLifetime)
            .Add<IEventStore>(sp => sp.GetRequiredService<TEventStore>(), withLifetime);
    }

    public static IServiceCollection AddEventStorePipeline(this IServiceCollection services,
        ServiceLifetime withLifetime = ServiceLifetime.Transient)
    {
        return services.Add(typeof(INotificationHandler<>), typeof(EventStorePipeline<>), withLifetime);
    }

    public static IServiceCollection AddValidationPipeline(this IServiceCollection services,
        ServiceLifetime withLifetime = ServiceLifetime.Transient)
    {
        return services.Add(typeof(IRequestPreProcessor<>), typeof(ValidationPipeline<>), withLifetime);
    }

    public static IServiceCollection AddCommandHandler<TCommand, TCommandHandler>(
        this IServiceCollection services, ServiceLifetime withLifetime = ServiceLifetime.Transient)
        where TCommand : ICommand
        where TCommandHandler : class, ICommandHandler<TCommand>
    {
        return services.Add<TCommandHandler>(withLifetime)
            .Add<IRequestHandler<TCommand, Unit>>(sp => sp.GetRequiredService<TCommandHandler>(), withLifetime)
            .Add<ICommandHandler<TCommand>>(sp => sp.GetRequiredService<TCommandHandler>(), withLifetime);
    }

    public static IServiceCollection AddQueryHandler<TQuery, TResponse, TQueryHandler>(
        this IServiceCollection services, ServiceLifetime withLifetime = ServiceLifetime.Transient)
        where TQuery : IQuery<TResponse>
        where TQueryHandler : class, IQueryHandler<TQuery, TResponse>
    {
        return services.Add<TQueryHandler>(withLifetime)
            .Add<IRequestHandler<TQuery, TResponse>>(sp => sp.GetRequiredService<TQueryHandler>(), withLifetime)
            .Add<IQueryHandler<TQuery, TResponse>>(sp => sp.GetRequiredService<TQueryHandler>(), withLifetime);
    }

    public static IServiceCollection AddEventHandler<TEvent, TEventHandler>(
        this IServiceCollection services,
        ServiceLifetime withLifetime = ServiceLifetime.Transient)
        where TEvent : IEvent
        where TEventHandler : class, IEventHandler<TEvent>
    {
        return services.Add<TEventHandler>(withLifetime)
            .Add<INotificationHandler<TEvent>>(sp => sp.GetRequiredService<TEventHandler>(), withLifetime)
            .Add<IEventHandler<TEvent>>(sp => sp.GetRequiredService<TEventHandler>(), withLifetime);
    }

    public static IServiceCollection AddAllCommandHandlers(
        this IServiceCollection services,
        ServiceLifetime withLifetime = ServiceLifetime.Transient,
        AssemblySelector from = AssemblySelector.ApplicationDependencies)
    {
        return services.Scan(scan => scan
            .FromAssemblies(from)
            .AddClasses(classes =>
                classes.AssignableTo(typeof(ICommandHandler<>))
                    .Where(c => !c.IsAbstract && !c.IsGenericTypeDefinition))
            .AsSelfWithInterfaces()
            .WithLifetime(withLifetime)
        );
    }

    public static IServiceCollection AddAllQueryHandlers(
        this IServiceCollection services,
        ServiceLifetime withLifetime = ServiceLifetime.Transient,
        AssemblySelector from = AssemblySelector.ApplicationDependencies)
    {
        return services.Scan(scan => scan
            .FromAssemblies(from)
            .AddClasses(classes =>
                classes.AssignableTo(typeof(IQueryHandler<,>))
                    .Where(c => !c.IsAbstract && !c.IsGenericTypeDefinition))
            .AsSelfWithInterfaces()
            .WithLifetime(withLifetime)
        );
    }

    public static IServiceCollection AddAllEventHandlers(
        this IServiceCollection services,
        ServiceLifetime withLifetime = ServiceLifetime.Transient,
        AssemblySelector from = AssemblySelector.ApplicationDependencies)
    {
        return services.Scan(scan => scan
            .FromAssemblies(from)
            .AddClasses(classes =>
                classes.AssignableTo(typeof(IEventHandler<>))
                    .Where(c => !c.IsAbstract && !c.IsGenericTypeDefinition))
            .AsSelfWithInterfaces()
            .WithLifetime(withLifetime)
        );
    }

    public static IServiceCollection AddAllDDDHandlers(
        this IServiceCollection services,
        ServiceLifetime withLifetime = ServiceLifetime.Transient,
        AssemblySelector from = AssemblySelector.ApplicationDependencies)
    {
        return services
            .AddAllCommandHandlers(withLifetime, from)
            .AddAllQueryHandlers(withLifetime, from)
            .AddAllEventHandlers(withLifetime, from);
    }

    public static IServiceCollection AddExternalEventConsumerBackgroundWorker(this IServiceCollection services)
    {
        return services.AddHostedService<ExternalEventConsumerBackgroundWorker>();
    }
}
