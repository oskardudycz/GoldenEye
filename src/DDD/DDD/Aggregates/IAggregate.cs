using System;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.DDD.Aggregates
{
    public interface IAggregate<TKey>: IHaveId<TKey>
    {
    }

    public interface IAggregate: IAggregate<Guid>
    {
    }
}
