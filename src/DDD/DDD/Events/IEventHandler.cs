using MediatR;

namespace GoldenEye.DDD.Events
{
    public interface IEventHandler<in TEvent>: INotificationHandler<TEvent>
        where TEvent : IEvent
    {
    }
}
