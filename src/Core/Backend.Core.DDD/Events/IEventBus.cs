using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.DDD.Events
{
    public interface IEventBus
    {
        Task Publish<TEvent>(TEvent @event) where TEvent : IEvent;
    }
}
