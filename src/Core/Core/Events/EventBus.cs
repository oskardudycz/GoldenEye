using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events.External;
using MediatR;

namespace GoldenEye.Events;

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

    public async Task Publish<TEvent>(TEvent @event, CancellationToken cancellationToken = default)
        where TEvent: IEvent
    {
        await mediator.Publish(@event, cancellationToken);

        if (@event is IExternalEvent externalEvent)
        {
            await externalEventProducer.Publish(externalEvent, cancellationToken);
        }
    }

    public async Task Publish(CancellationToken cancellationToken, params IEvent[] events)
    {
        foreach (var @event in events)
        {
            await Publish(@event, cancellationToken);
        }
    }

    public Task PublishParallel(CancellationToken cancellationToken, params IEvent[] events)
    {
        var tasks = events.Select(@event => Publish(@event, cancellationToken)).ToList();

        return Task.WhenAll(tasks);
    }
}