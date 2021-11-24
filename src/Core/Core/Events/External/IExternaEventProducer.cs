using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Events.External;

public interface IExternalEventProducer
{
    Task Publish(IExternalEvent @event, CancellationToken cancellationToken = default);
}