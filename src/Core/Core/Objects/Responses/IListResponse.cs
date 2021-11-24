using System.Collections.Generic;

namespace GoldenEye.Objects.Responses;

public interface IListResponse<T>
{
    IList<T> Items { get; }
}