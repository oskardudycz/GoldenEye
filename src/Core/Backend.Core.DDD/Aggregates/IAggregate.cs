using System;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.DDD.Aggregates
{
    public interface IAggregate<TKey>: IHasId<TKey>
    {
    }

    public interface IAggregate: IAggregate<Guid>
    {
    }
}
