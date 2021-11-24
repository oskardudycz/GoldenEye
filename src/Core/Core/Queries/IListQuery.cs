using System.Collections.Generic;

namespace GoldenEye.Queries;

public interface IListQuery<TResponse>: IQuery<IReadOnlyList<TResponse>>
{
}