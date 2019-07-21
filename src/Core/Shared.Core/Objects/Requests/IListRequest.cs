using System.Collections.Generic;

namespace GoldenEye.Shared.Core.Objects.Requests
{
    public interface IListRequest<T>: IRequest
    {
        IList<T> Items { get; }
    }
}
