using System;
using MediatR;

namespace GoldenEye.Backend.Core.DDD.Events
{
    public interface IEvent: INotification
    {
        Guid StreamId { get; }
    }
}
