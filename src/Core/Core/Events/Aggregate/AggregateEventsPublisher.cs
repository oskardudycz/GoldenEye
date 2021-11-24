using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Aggregates;
using GoldenEye.Extensions.Collections;

namespace GoldenEye.Events.Aggregate;

public class AggregateEventsPublisher: IAggregateEventsPublisher
{
    private readonly IEventBus eventBus;
    private readonly Queue<IEvent> pendingEvents = new();

    public AggregateEventsPublisher(IEventBus eventBus)
    {
        this.eventBus = eventBus;
    }

    public IEvent[] EnqueueEventsFrom(IAggregate aggregate)
    {
        var uncommittedEvents = aggregate.DequeueUncommittedEvents();

        pendingEvents.EnqueueRange(uncommittedEvents);

        return uncommittedEvents;
    }

    public bool TryEnqueueEventsFrom(object entity, out IEvent[] uncommittedEvents)
    {
        if (entity is not IAggregate aggregate)
        {
            uncommittedEvents = null;
            return false;
        }

        uncommittedEvents = EnqueueEventsFrom(aggregate);
        return true;
    }

    public Task Publish(CancellationToken cancellationToken = default)
    {
        var eventsToPublish = pendingEvents.ToArray();
        pendingEvents.Clear();

        return eventBus.Publish(cancellationToken, eventsToPublish);
    }
}