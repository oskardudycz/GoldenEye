using Microsoft.Extensions.DependencyInjection;
using MediatR;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Backend.Core.DDD.Events;

namespace GoldenEye.Backend.Core.DDD.Registration
{
    public static class Registration
    {
        public static void AddDDD(this IServiceCollection services)
        {
            services.AddScoped<IMediator, Mediator>();
            services.AddTransient<SingleInstanceFactory>(sp => t => sp.GetService(t));
            services.AddTransient<MultiInstanceFactory>(sp => t => sp.GetServices(t));
            
            services.AddTransient<ICommandBus, CommandBus>();
            services.AddTransient<IQueryBus, QueryBus>();
            services.AddTransient<IEventBus, EventBus>();
        }
        
        public static void RegisterCommandHandler<TCommand, TCommandHandler>(this IServiceCollection services)
            where TCommand : ICommand
            where TCommandHandler : class, ICommandHandler<TCommand>
        {
            services.AddTransient<TCommandHandler>();
            services.AddTransient<IRequestHandler<TCommand>>(sp => sp.GetService<TCommandHandler>());
            services.AddTransient<ICommandHandler<TCommand>>(sp => sp.GetService<TCommandHandler>());
        }

        public static void RegisterAsyncCommandHandler<TCommand, TCommandHandler>(this IServiceCollection services)
            where TCommand : ICommand
            where TCommandHandler : class, IAsyncCommandHandler<TCommand>
        {
            services.AddTransient<TCommandHandler>();
            services.AddTransient<IAsyncRequestHandler<TCommand>>(sp => sp.GetService<TCommandHandler>());
            services.AddTransient<IAsyncCommandHandler<TCommand>>(sp => sp.GetService<TCommandHandler>());
        }

        public static void RegisterQueryHandler<TQuery, TResponse, TQueryHandler>(this IServiceCollection services)
            where TQuery : IQuery<TResponse>
            where TQueryHandler : class, IQueryHandler<TQuery, TResponse>
        {
            services.AddTransient<TQueryHandler>();
            services.AddTransient<IRequestHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>());
            services.AddTransient<IQueryHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>());
        }

        public static void RegisterAsyncQueryHandler<TQuery, TResponse, TQueryHandler>(this IServiceCollection services)
            where TQuery : IQuery<TResponse>
            where TQueryHandler : class, IAsyncQueryHandler<TQuery, TResponse>
        {
            services.AddTransient<TQueryHandler>();
            services.AddTransient<IAsyncRequestHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>());
            services.AddTransient<IAsyncQueryHandler<TQuery, TResponse>>(sp => sp.GetService<TQueryHandler>());
        }

        public static void RegisterEventHandler<TEvent, TEventHandler>(this IServiceCollection services)
            where TEvent : IEvent
            where TEventHandler : class, IEventHandler<TEvent>
        {
            services.AddTransient<TEventHandler>();
            services.AddTransient<INotificationHandler<TEvent>>(sp => sp.GetService<TEventHandler>());
            services.AddTransient<IEventHandler<TEvent>>(sp => sp.GetService<TEventHandler>());
        }

        public static void RegisterAsyncEventHandler<TEvent, TEventHandler>(this IServiceCollection services)
            where TEvent : IEvent
            where TEventHandler : class, IAsyncEventHandler<TEvent>
        {
            services.AddTransient<TEventHandler>();
            services.AddTransient<IAsyncNotificationHandler<TEvent>>(sp => sp.GetService<TEventHandler>());
            services.AddTransient<IAsyncEventHandler<TEvent>>(sp => sp.GetService<TEventHandler>());
        }
    }
}
