using System;
using MediatR;

namespace GoldenEye.DDD.Events
{
    public interface IEvent: INotification
    {
        Guid StreamId { get; }
    }
}
