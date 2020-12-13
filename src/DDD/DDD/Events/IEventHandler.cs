using MediatR;

namespace GoldenEye.Backend.Core.DDD.Events
{
    public interface IEventHandler<in TEvent>: INotificationHandler<TEvent>
        where TEvent : IEvent
    {
    }
}
