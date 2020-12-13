using System.Collections.Generic;

namespace GoldenEye.Core.Objects.Requests
{
    public interface IListRequest<T>: IRequest
    {
        IList<T> Items { get; }
    }
}
