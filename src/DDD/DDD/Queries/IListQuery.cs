using System.Collections.Generic;

namespace GoldenEye.DDD.Queries
{
    public interface IListQuery<TResponse>: IQuery<IReadOnlyList<TResponse>>
    {
    }
}
