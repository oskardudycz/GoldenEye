using System;
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
            return Publish(cancellationToken, @event);
        }

        public async Task Publish(CancellationToken cancellationToken, params IEvent[] events)
        {
            foreach (var @event in events)
            {
                await mediator.Publish(@event, cancellationToken);

                if (@event is IExternalEvent externalEvent)
                    await externalEventProducer.Publish(externalEvent, cancellationToken);
            }
        }
    }
}
