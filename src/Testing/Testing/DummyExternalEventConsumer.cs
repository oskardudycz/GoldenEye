using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events.External;

namespace GoldenEye.Testing;

public class DummyExternalEventConsumer: IExternalEventConsumer
{
    public Task Start(CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
}