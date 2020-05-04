using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Backend.Core.DDD.Events.Logging;
using GoldenEye.Backend.Core.DDD.Events.Store;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Backend.Core.DDD.Validation;
using GoldenEye.Shared.Core.Extensions.DependencyInjection;
using MediatR;
using MediatR.Pipeline;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Core.DDD.Registration
{
    public static class Registration
    {
        public static IServiceCollection AddDDD(this IServiceCollection services,
            ServiceLifetime withLifetime = ServiceLifetime.Transient)
        {
            return services.AddScoped<IMediator, Mediator>()
                .Add<ServiceFactory>(sp => t => sp.GetService(t), withLifetime)
                .Add(typeof(IPipelineBehavior<,>), typeof(RequestPreProcessorBehavior<,>), withLifetime)
                .Add<ICommandBus, CommandBus>(withLifetime)
                .Add<IQueryBus, QueryBus>(withLifetime)
                .Add<IEventBus, EventBus>(withLifetime);
        }

        public static IServiceCollection AddEventStore<TEventStore>(this IServiceCollection services,
            ServiceLifetime withLifetime = ServiceLifetime.Transient)
            where TEventStore : class, IEventStore
        {
            return services.Add<TEventStore, TEventStore>(withLifetime)
                .Add<IEventStore>(sp => sp.GetService<TEventStore>(), withLifetime);
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

        public static IServiceCollection RegisterCommandHandler<TCommand, TCommandHandler>(
            this IServiceCollection services, ServiceLifetime withLifetime = ServiceLifetime.Transient)
            where TCommand : ICommand
            where TCommandHandler : class, ICommandHandler<TCommand>
        {
            return services.Add<TCommandHandler>(withLifetime)
                .Add<IRequestHandler<TCommand, Unit>>(sp => sp.GetService<TCommandHandler>(), withLifetime)
                .Add<ICommandHandler<TCommand>>(sp => sp.GetService<TCommandHandler>(), withLifetime);
        }

        public static IServiceCollection RegisterQueryHandler<TQuery, TResponse, TQueryHandler>(
            this IServiceCollection services, ServiceLifetime withLifetime = ServiceLifetime.Transient)
            where TQuery : IQuery<TResponse>
            where TQueryHandler : class, IQueryHandler<TQuery, TResponse>
        {
            return services.Add<TQueryHandler>(withLifetime)
                .Add<IRequestHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>(), withLifetime)
                .Add<IQueryHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>(), withLifetime);
        }

        public static IServiceCollection RegisterEventHandler<TEvent, TEventHandler>(
            this IServiceCollection services,
            ServiceLifetime withLifetime = ServiceLifetime.Transient)
            where TEvent : IEvent
            where TEventHandler : class, IEventHandler<TEvent>
        {
            return services.Add<TEventHandler>(withLifetime)
                .Add<INotificationHandler<TEvent>>(sp => sp.GetService<TEventHandler>(), withLifetime)
                .Add<IEventHandler<TEvent>>(sp => sp.GetService<TEventHandler>(), withLifetime);
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
    }
}
