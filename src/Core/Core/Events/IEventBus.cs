using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Events
{
    public interface IEventBus
    {
        Task PublishAsync<TEvent>(TEvent @event, CancellationToken cancellationToken = default) where TEvent : IEvent;
    }
}
