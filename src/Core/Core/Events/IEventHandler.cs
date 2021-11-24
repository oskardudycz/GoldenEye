using MediatR;

namespace GoldenEye.Events;

public interface IEventHandler<in TEvent>: INotificationHandler<TEvent>
    where TEvent : IEvent
{
}