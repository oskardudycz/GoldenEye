using System.Collections.Generic;
using GoldenEye.Backend.Core.DDD.Aggregates;

namespace GoldenEye.Backend.Core.DDD.Events
{
    public interface IEventSource: IAggregate
    {
        Queue<IEvent> PendingEvents { get; }
    }
}
