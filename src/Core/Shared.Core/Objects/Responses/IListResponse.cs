using System.Collections.Generic;

namespace GoldenEye.Shared.Core.Objects.Responses
{
    public interface IListResponse<T>
    {
        IList<T> Items { get; }
    }
}
