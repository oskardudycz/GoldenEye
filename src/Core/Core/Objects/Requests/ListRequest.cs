using System.Collections.Generic;

namespace GoldenEye.Objects.Requests;

/// <summary>
///     Class to send list of records from service
/// </summary>
public class ListRequest<T>: IListRequest<T>
{
    /// <summary>
    ///     Constructor
    /// </summary>
    /// <param name="items">List of records</param>
    private ListRequest(IList<T> items)
    {
        Items = items;
    }

    /// <summary>
    ///     List of records
    /// </summary>
    public IList<T> Items { get; }

    /// <summary>
    ///     Creation metod of class object
    /// </summary>
    /// <param name="items">List of records</param>
    /// <returns></returns>
    public static ListRequest<T> Create(IList<T> items)
    {
        if (items == null)
            items = new List<T>();

        return new ListRequest<T>(items);
    }
}