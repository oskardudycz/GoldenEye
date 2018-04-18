using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.DDD.Events
{
    public interface IEventBus
    {
        Task PublishAsync<TEvent>(TEvent @event, CancellationToken cancellationToken = default(CancellationToken)) where TEvent : IEvent;
    }
}