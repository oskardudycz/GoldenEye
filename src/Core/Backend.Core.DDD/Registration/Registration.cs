using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Backend.Core.DDD.Events.Logging;
using GoldenEye.Backend.Core.DDD.Events.Store;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Backend.Core.DDD.Validation;
using MediatR;
using MediatR.Pipeline;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Core.DDD.Registration
{
    public static class Registration
    {
        public static void AddDDD(this IServiceCollection services)
        {
            services.AddScoped<IMediator, Mediator>();
            services.AddTransient<SingleInstanceFactory>(sp => t => sp.GetService(t));
            services.AddTransient<MultiInstanceFactory>(sp => t => sp.GetServices(t));
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(RequestPreProcessorBehavior<,>));

            services.AddTransient<ICommandBus, CommandBus>();
            services.AddTransient<IQueryBus, QueryBus>();
            services.AddTransient<IEventBus, EventBus>();
        }

        public static void AddEventStore<TEventStore>(this IServiceCollection services)
            where TEventStore : class, IEventStore
        {
            services.AddTransient<TEventStore, TEventStore>();
            services.AddTransient<IEventStore>(sp => sp.GetService<TEventStore>());
        }

        public static void AddEventStorePipeline(this IServiceCollection services)
        {
            services.AddTransient(typeof(INotificationHandler<>), typeof(EventStorePipeline<>));
        }

        public static void AddValidationPipeline(this IServiceCollection services)
        {
            services.AddTransient(typeof(IRequestPreProcessor<>), typeof(ValidationPipeline<>));
        }

        public static void RegisterCommandHandler<TCommand, TCommandHandler>(this IServiceCollection services)
            where TCommand : ICommand
            where TCommandHandler : class, ICommandHandler<TCommand>
        {
            services.AddTransient<TCommandHandler>();
            services.AddTransient<IRequestHandler<TCommand>>(sp => sp.GetService<TCommandHandler>());
            services.AddTransient<ICommandHandler<TCommand>>(sp => sp.GetService<TCommandHandler>());
        }

        public static void RegisterQueryHandler<TQuery, TResponse, TQueryHandler>(this IServiceCollection services)
            where TQuery : IQuery<TResponse>
            where TQueryHandler : class, IQueryHandler<TQuery, TResponse>
        {
            services.AddTransient<TQueryHandler>();
            services.AddTransient<IRequestHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>());
            services.AddTransient<IQueryHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>());
        }

        public static void RegisterEventHandler<TEvent, TEventHandler>(this IServiceCollection services)
            where TEvent : IEvent
            where TEventHandler : class, IEventHandler<TEvent>
        {
            services.AddTransient<TEventHandler>();
            services.AddTransient<INotificationHandler<TEvent>>(sp => sp.GetService<TEventHandler>());
            services.AddTransient<IEventHandler<TEvent>>(sp => sp.GetService<TEventHandler>());
        }
    }
}