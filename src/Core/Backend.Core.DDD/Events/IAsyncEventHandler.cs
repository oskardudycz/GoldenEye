using MediatR;

namespace GoldenEye.Backend.Core.DDD.Events
{
    public interface IAsyncEventHandler<in TEvent> : IAsyncNotificationHandler<TEvent>
           where TEvent : IEvent
    {
    }
}
