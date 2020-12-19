using System;
using GoldenEye.Entities;
using GoldenEye.Events;

namespace GoldenEye.Aggregates
{
    public interface IAggregate<out TKey>: IEntity<TKey>
    {
        int Version { get; }

        IEvent[] DequeueUncommittedEvents();
    }

    public interface IAggregate: IAggregate<Guid>
    {
    }
}
