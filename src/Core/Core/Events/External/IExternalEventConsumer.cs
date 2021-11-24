using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Events.External;

public interface IExternalEventConsumer
{
    Task Start(CancellationToken cancellationToken);
}