using System.Collections.Generic;
using GoldenEye.Aggregates;

namespace GoldenEye.Events
{
    public interface IEventSource: IAggregate
    {
        Queue<IEvent> PendingEvents { get; }
    }
}
