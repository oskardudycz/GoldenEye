using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Aggregates;

namespace GoldenEye.Events.Aggregate;

public interface IAggregateEventsPublisher
{
    IEvent[] EnqueueEventsFrom(IAggregate aggregate);

    bool TryEnqueueEventsFrom(object entity, out IEvent[] uncommittedEvents);

    Task Publish(CancellationToken cancellationToken = default);
}