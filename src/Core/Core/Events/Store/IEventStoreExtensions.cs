using System;
using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Events.Store;

public static class IEventStoreExtensions
{
    public static Task Append(this IEventStore eventStore, Guid streamId, CancellationToken cancellationToken, params IEvent[] events)
    {
        return eventStore.Append(streamId, null, cancellationToken, events);
    }
}