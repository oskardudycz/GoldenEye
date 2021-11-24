using System;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Aggregates;

namespace GoldenEye.Events.Aggregate;

public class NulloAggregateEventsPublisher: IAggregateEventsPublisher
{
    public IEvent[] EnqueueEventsFrom(IAggregate aggregate)
    {
        return Array.Empty<IEvent>();
    }

    public bool TryEnqueueEventsFrom(object entity, out IEvent[] uncommittedEvents)
    {
        if (entity is not IAggregate aggregate)
        {
            uncommittedEvents = null;
            return false;
        }

        uncommittedEvents = aggregate.DequeueUncommittedEvents();
        return true;
    }

    public Task Publish(CancellationToken cancellationToken = default)
    {
        return Task.CompletedTask;
    }
}