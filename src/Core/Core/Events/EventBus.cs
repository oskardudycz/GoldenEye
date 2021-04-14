using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events.External;
using MediatR;

namespace GoldenEye.Events
{
    public class EventBus: IEventBus
    {
        private readonly IMediator mediator;
        private readonly IExternalEventProducer externalEventProducer;

        public EventBus(
            IMediator mediator,
            IExternalEventProducer externalEventProducer
        )
        {
            this.mediator = mediator ?? throw new ArgumentNullException(nameof(mediator));
            this.externalEventProducer = externalEventProducer?? throw new ArgumentNullException(nameof(externalEventProducer));
        }

        public Task Publish<TEvent>(TEvent @event, CancellationToken cancellationToken = default)
            where TEvent: IEvent
        {
            return PublishInteral(@event, cancellationToken);
        }

        public async Task Publish(CancellationToken cancellationToken, params IEvent[] events)
        {
            foreach (var @event in events)
            {
                await PublishInteral(@event, cancellationToken);
            }
        }

        public async Task PublishParallel(CancellationToken cancellationToken, params IEvent[] events)
        {
            var tasks = new List<Task>();
            foreach (var @event in events)
            {
                tasks.Add(Task.Run(() => PublishInteral(@event, cancellationToken)));
            }

            await Task.WhenAll(tasks);
        }

        private async Task PublishInteral(IEvent @event, CancellationToken cancellationToken)
        {
            await mediator.Publish(@event, cancellationToken);

            if (@event is IExternalEvent externalEvent)
            {
                await externalEventProducer.Publish(externalEvent, cancellationToken);
            }
        }
    }
}
