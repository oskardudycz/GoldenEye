using System.Collections.Generic;

namespace GoldenEye.Objects.Requests;

public interface IListRequest<T>: IRequest
{
    IList<T> Items { get; }
}