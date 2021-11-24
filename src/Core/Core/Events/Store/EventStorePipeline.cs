using System;
using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Events.Store;

public class EventStorePipeline<TEvent>: IEventHandler<TEvent>
    where TEvent : IEvent
{
    private readonly IEventStore eventStore;

    public EventStorePipeline(IEventStore eventStore)
    {
        this.eventStore = eventStore ?? throw new ArgumentException(nameof(eventStore));
    }

    public async Task Handle(TEvent @event, CancellationToken cancellationToken)
    {
        await eventStore.Append(@event.StreamId, cancellationToken, @event);
        await eventStore.SaveChanges(cancellationToken);
    }
}