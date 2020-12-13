using System;
using GoldenEye.Core.Objects.General;

namespace GoldenEye.DDD.Aggregates
{
    public interface IAggregate<TKey>: IHaveId<TKey>
    {
    }

    public interface IAggregate: IAggregate<Guid>
    {
    }
}
