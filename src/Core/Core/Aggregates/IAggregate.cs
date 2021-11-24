using System;
using GoldenEye.Entities;
using GoldenEye.Events;
using GoldenEye.Objects.Versioning;

namespace GoldenEye.Aggregates;

public interface IAggregate<out TKey>: IEntity<TKey>, IHaveVersion
{
    IEvent[] DequeueUncommittedEvents();
}

public interface IAggregate: IAggregate<Guid>
{
}