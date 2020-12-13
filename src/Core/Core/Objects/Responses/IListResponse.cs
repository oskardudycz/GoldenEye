using System.Collections.Generic;

namespace GoldenEye.Core.Objects.Responses
{
    public interface IListResponse<T>
    {
        IList<T> Items { get; }
    }
}
