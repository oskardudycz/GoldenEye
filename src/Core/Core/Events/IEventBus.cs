using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Events;

public interface IEventBus
{
    Task Publish(CancellationToken cancellationToken, params IEvent[] events);
    Task PublishParallel(CancellationToken cancellationToken, params IEvent[] events);
    Task Publish<TEvent>(TEvent @event, CancellationToken cancellationToken = default) where TEvent : IEvent;
}