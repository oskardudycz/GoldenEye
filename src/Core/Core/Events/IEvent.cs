using System;
using MediatR;

namespace GoldenEye.Events;

public interface IEvent: INotification
{
    Guid StreamId { get; }
}