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
        public static void AddDDD(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        {
            services.AddScoped<IMediator, Mediator>();
            services.Add<ServiceFactory>(sp => t => sp.GetService(t), serviceLifetime);
            services.Add(typeof(IPipelineBehavior<,>), typeof(RequestPreProcessorBehavior<,>), serviceLifetime);

            services.Add<ICommandBus, CommandBus>(serviceLifetime);
            services.Add<IQueryBus, QueryBus>(serviceLifetime);
            services.Add<IEventBus, EventBus>(serviceLifetime);
        }

        public static void AddEventStore<TEventStore>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TEventStore : class, IEventStore
        {
            services.Add<TEventStore, TEventStore>(serviceLifetime);
            services.Add<IEventStore>(sp => sp.GetService<TEventStore>(), serviceLifetime);
        }

        public static void AddEventStorePipeline(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        {
            services.Add(typeof(INotificationHandler<>), typeof(EventStorePipeline<>), serviceLifetime);
        }

        public static void AddValidationPipeline(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
        {
            services.Add(typeof(IRequestPreProcessor<>), typeof(ValidationPipeline<>), serviceLifetime);
        }

        public static void RegisterCommandHandler<TCommand, TCommandHandler>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TCommand : ICommand
            where TCommandHandler : class, ICommandHandler<TCommand>
        {
            services.Add<TCommandHandler>(serviceLifetime);
            services.Add<IRequestHandler<TCommand, Unit>>(sp => sp.GetService<TCommandHandler>(), serviceLifetime);
            services.Add<ICommandHandler<TCommand>>(sp => sp.GetService<TCommandHandler>(), serviceLifetime);
        }

        public static void RegisterQueryHandler<TQuery, TResponse, TQueryHandler>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TQuery : IQuery<TResponse>
            where TQueryHandler : class, IQueryHandler<TQuery, TResponse>
        {
            services.Add<TQueryHandler>(serviceLifetime);
            services.Add<IRequestHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>(), serviceLifetime);
            services.Add<IQueryHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>(), serviceLifetime);
        }

        public static void RegisterEventHandler<TEvent, TEventHandler>(this IServiceCollection services, ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
            where TEvent : IEvent
            where TEventHandler : class, IEventHandler<TEvent>
        {
            services.Add<TEventHandler>(serviceLifetime);
            services.Add<INotificationHandler<TEvent>>(sp => sp.GetService<TEventHandler>(), serviceLifetime);
            services.Add<IEventHandler<TEvent>>(sp => sp.GetService<TEventHandler>(), serviceLifetime);
        }
    }
}