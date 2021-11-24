using System.Collections.Generic;
using System.Linq;

namespace GoldenEye.Objects.Responses;

public class PagedResponse<T>
{
    public IReadOnlyCollection<T> Items { get; }

    public long TotalItemCount { get; }

    public bool HasNextPage { get; }

    public PagedResponse(IEnumerable<T> items, long totalItemCount, bool hasNextPage)
    {
        Items = items.ToList();
        TotalItemCount = totalItemCount;
        HasNextPage = hasNextPage;
    }
}