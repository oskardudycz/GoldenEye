using System.Collections.Generic;

namespace GoldenEye.Backend.Core.DDD.Queries
{
    public interface IListQuery<TResponse> : IQuery<IReadOnlyList<TResponse>>
    {
    }
}