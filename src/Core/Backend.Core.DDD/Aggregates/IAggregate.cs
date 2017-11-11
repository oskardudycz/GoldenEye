using GoldenEye.Shared.Core.Objects.General;
using System;

namespace GoldenEye.Backend.Core.DDD.Aggregates
{
    public interface IAggregate<TKey> : IHasId<TKey>
    {

    }
    public interface IAggregate : IAggregate<Guid>
    {

    }
}
