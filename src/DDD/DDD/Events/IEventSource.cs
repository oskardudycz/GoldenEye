using System.Collections.Generic;
using GoldenEye.DDD.Aggregates;

namespace GoldenEye.DDD.Events
{
    public interface IEventSource: IAggregate
    {
        Queue<IEvent> PendingEvents { get; }
    }
}
