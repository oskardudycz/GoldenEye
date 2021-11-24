using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events;
using GoldenEye.Events.External;

namespace GoldenEye.Testing;

public class DummyExternalEventProducer: IExternalEventProducer
{
    public IList<IExternalEvent> PublishedEvents { get; } = new List<IExternalEvent>();

    public Task Publish(IExternalEvent @event, CancellationToken cancellationToken = default)
    {
        PublishedEvents.Add(@event);

        return Task.CompletedTask;
    }
}