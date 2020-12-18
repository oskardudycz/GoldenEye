using System;
using GoldenEye.Objects.General;

namespace GoldenEye.Aggregates
{
    public interface IAggregate<TKey>: IHaveId<TKey>
    {
    }

    public interface IAggregate: IAggregate<Guid>
    {
    }
}
