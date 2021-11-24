using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Events.External;

public class NulloExternalEventProducer : IExternalEventProducer
{
    public Task Publish(IExternalEvent @event, CancellationToken cancellationToken = default)
    {
        return Task.CompletedTask;
    }
}