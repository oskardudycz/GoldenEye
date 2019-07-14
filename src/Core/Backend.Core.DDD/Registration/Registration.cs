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
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace GoldenEye.Backend.Core.DDD.Registration
{
    public static class Registration
    {
        public static void AddDDD(this IServiceCollection services, ServiceLifetime withLifetime = ServiceLifetime.Transient)
        {
            services.AddScoped<IMediator, Mediator>();
            services.Add<ServiceFactory>(sp => t => sp.GetService(t), withLifetime);
            services.Add(typeof(IPipelineBehavior<,>), typeof(RequestPreProcessorBehavior<,>), withLifetime);

            services.Add<ICommandBus, CommandBus>(withLifetime);
            services.Add<IQueryBus, QueryBus>(withLifetime);
            services.Add<IEventBus, EventBus>(withLifetime);
        }

        public static void AddEventStore<TEventStore>(this IServiceCollection services, ServiceLifetime withLifetime = ServiceLifetime.Transient)
            where TEventStore : class, IEventStore
        {
            services.Add<TEventStore, TEventStore>(withLifetime);
            services.Add<IEventStore>(sp => sp.GetService<TEventStore>(), withLifetime);
        }

        public static void AddEventStorePipeline(this IServiceCollection services, ServiceLifetime withLifetime = ServiceLifetime.Transient)
        {
            services.Add(typeof(INotificationHandler<>), typeof(EventStorePipeline<>), withLifetime);
        }

        public static void AddValidationPipeline(this IServiceCollection services, ServiceLifetime withLifetime = ServiceLifetime.Transient)
        {
            services.Add(typeof(IRequestPreProcessor<>), typeof(ValidationPipeline<>), withLifetime);
        }

        public static void RegisterCommandHandler<TCommand, TCommandHandler>(this IServiceCollection services, ServiceLifetime withLifetime = ServiceLifetime.Transient)
            where TCommand : ICommand
            where TCommandHandler : class, ICommandHandler<TCommand>
        {
            services.Add<TCommandHandler>(withLifetime);
            services.Add<IRequestHandler<TCommand, Unit>>(sp => sp.GetService<TCommandHandler>(), withLifetime);
            services.Add<ICommandHandler<TCommand>>(sp => sp.GetService<TCommandHandler>(), withLifetime);
        }

        public static void RegisterQueryHandler<TQuery, TResponse, TQueryHandler>(this IServiceCollection services, ServiceLifetime withLifetime = ServiceLifetime.Transient)
            where TQuery : IQuery<TResponse>
            where TQueryHandler : class, IQueryHandler<TQuery, TResponse>
        {
            services.Add<TQueryHandler>(withLifetime);
            services.Add<IRequestHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>(), withLifetime);
            services.Add<IQueryHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>(), withLifetime);
        }

        public static void RegisterEventHandler<TEvent, TEventHandler>(
            this IServiceCollection services,
            ServiceLifetime withLifetime = ServiceLifetime.Transient)
            where TEvent : IEvent
            where TEventHandler : class, IEventHandler<TEvent>
        {
            services.Add<TEventHandler>(withLifetime);
            services.Add<INotificationHandler<TEvent>>(sp => sp.GetService<TEventHandler>(), withLifetime);
            services.Add<IEventHandler<TEvent>>(sp => sp.GetService<TEventHandler>(), withLifetime);
        }

        public static IServiceCollection AddAllCommandHandlers(
            this IServiceCollection services,
            ServiceLifetime withLifetime = ServiceLifetime.Transient,
            AssemblySelector from = AssemblySelector.ApplicationDependencies)
        {
            services.Scan(scan => scan
                .FromAssemblies(from)
                .AddClasses(classes => classes.AssignableTo(typeof(ICommandHandler<>)))
                    .AsSelfWithInterfaces()
                    .WithLifetime(withLifetime)
                 );

            return services;
        }

        public static IServiceCollection AddAllQueryHandlers(
            this IServiceCollection services,
            ServiceLifetime withLifetime = ServiceLifetime.Transient,
            AssemblySelector from = AssemblySelector.ApplicationDependencies)
        {
            services.Scan(scan => scan
                .FromAssemblies(from)
                .AddClasses(classes => classes.AssignableTo(typeof(IQueryHandler<,>)))
                    .AsSelfWithInterfaces()
                    .WithLifetime(withLifetime)
                 );

            return services;
        }

        public static IServiceCollection AddAllEventHandlers(
            this IServiceCollection services,
            ServiceLifetime withLifetime = ServiceLifetime.Transient,
            AssemblySelector from = AssemblySelector.ApplicationDependencies)
        {
            services.Scan(scan => scan
                .FromAssemblies(from)
                .AddClasses(classes => classes.AssignableTo(typeof(IEventHandler<>)).NotInNamespaceOf(typeof(EventStorePipeline<>)))
                    .AsSelfWithInterfaces()
                    .WithLifetime(withLifetime)
                 );

            return services;
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