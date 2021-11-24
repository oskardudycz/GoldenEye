using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using GoldenEye.Extensions.Basic;
using GoldenEye.Objects.General;
using GoldenEye.Objects.Order;

namespace GoldenEye.Extensions.Collections;

public static class EnumerableExtensions
{
    public static bool IsEmpty<T>(this IEnumerable<T> collection)
    {
        return !collection.Any();
    }

    public static bool IsNotNullAndNotEmpty<T>(this IEnumerable<T> collection)
    {
        return collection != null && !IsEmpty(collection);
    }

    public static void ForEach<T>(this IEnumerable<T> list, Action<T> action)
    {
        foreach (var element in list) action(element);
    }

    public static void ForEach<T>(this IEnumerable<T> list, Action<T, int> action)
    {
        var index = 0;
        foreach (var element in list)
        {
            action(element, index);
            index++;
        }
    }

    public static void ForEach(this IEnumerable list, Action<object> action)
    {
        foreach (var element in list) action(element);
    }

    public static IEnumerable<TResult> Select<T, TResult>(this IEnumerable<T> source,
        Func<T, int, TResult> projection)
    {
        var index = 0;
        using (var iterator = source.GetEnumerator())
        {
            if (!iterator.MoveNext()) yield break;
            do
            {
                yield return projection(iterator.Current, index);
                index++;
            } while (iterator.MoveNext());
        }
    }

    public static IEnumerable<TResult> Select<T, TResult>(this IList<T> source, Func<T, int, TResult> projection)
    {
        var index = 0;
        using (var iterator = source.GetEnumerator())
        {
            if (!iterator.MoveNext()) yield break;
            do
            {
                yield return projection(iterator.Current, index);
                index++;
            } while (iterator.MoveNext());
        }
    }

    public static IEnumerable<TResult> SelectWithPrevious<TSource, TResult>(this IEnumerable<TSource> source,
        Func<TSource, TSource, TResult> projection)
    {
        using (var iterator = source.GetEnumerator())
        {
            if (!iterator.MoveNext()) yield break;
            var previous = iterator.Current;
            while (iterator.MoveNext())
            {
                yield return projection(previous, iterator.Current);
                previous = iterator.Current;
            }
        }
    }

    public static TResult MaxOrDefault<TSource, TResult>(this IQueryable<TSource> source,
        Expression<Func<TSource, TResult>> selector)
    {
        return !source.Any() ? ObjectExtensions.GetDefault<TResult>() : source.Max(selector);
    }

    public static TResult MinOrDefault<TSource, TResult>(this IQueryable<TSource> source,
        Expression<Func<TSource, TResult>> selector)
    {
        return !source.Any() ? ObjectExtensions.GetDefault<TResult>() : source.Min(selector);
    }

    public static TProperty NonZeroAverage<TSource, TProperty>(this IEnumerable<TSource> source,
        Func<TSource, TProperty> selector)
    {
        if (typeof(TProperty) == typeof(int))
            return source.Select(selector.CastTo<Func<TSource, int>>()).Where(el => el != 0).ToList().Average()
                .ConvertTo<TProperty>();

        if (typeof(TProperty) == typeof(int?))
            return source.Select(selector.CastTo<Func<TSource, int?>>()).Where(el => el != 0).ToList().Average()
                .ConvertTo<TProperty>();

        if (typeof(TProperty) == typeof(decimal))
            return source.Select(selector.CastTo<Func<TSource, decimal>>()).Where(el => el != 0).ToList().Average()
                .ConvertTo<TProperty>();

        if (typeof(TProperty) == typeof(decimal?))
            return source.Select(selector.CastTo<Func<TSource, decimal?>>()).Where(el => el != 0).ToList().Average()
                .ConvertTo<TProperty>();

        throw new ArgumentOutOfRangeException("selector");
    }

    public static TProperty Average<TSource, TProperty>(this IEnumerable<TSource> source,
        Func<TSource, TProperty> selector)
    {
        if (typeof(TProperty) == typeof(int))
            return source.Average(selector.CastTo<Func<TSource, int>>()).ConvertTo<TProperty>();

        if (typeof(TProperty) == typeof(int?))
            return source.Average(selector.CastTo<Func<TSource, int?>>()).ConvertTo<TProperty>();

        if (typeof(TProperty) == typeof(decimal))
            return source.Average(selector.CastTo<Func<TSource, decimal>>()).ConvertTo<TProperty>();

        if (typeof(TProperty) == typeof(decimal?))
            return source.Average(selector.CastTo<Func<TSource, decimal?>>()).ConvertTo<TProperty>();

        throw new ArgumentOutOfRangeException("selector");
    }

    //public static TProperty Sum<TSource, TProperty>(this IEnumerable<TSource> source, Func<TSource, TProperty> selector)
    //{
    //    if (typeof(TProperty) == typeof(int))
    //        return source.Sum(selector.CastTo<Func<TSource, int>>()).ConvertTo<TProperty>();

    //    if (typeof(TProperty) == typeof(int?))
    //        return source.Sum(selector.CastTo<Func<TSource, int?>>()).ConvertTo<TProperty>();

    //    if (typeof(TProperty) == typeof(decimal))
    //        return source.Sum(selector.CastTo<Func<TSource, decimal>>()).ConvertTo<TProperty>();

    //    if (typeof(TProperty) == typeof(decimal?))
    //        return source.Sum(selector.CastTo<Func<TSource, decimal?>>()).ConvertTo<TProperty>();

    //    throw new ArgumentOutOfRangeException("selector");
    //}

    public static IEnumerable<TSource> Page<TSource>(this IEnumerable<TSource> source, int page, int? pageSize)
    {
        if (page < 0) throw new ArgumentException("Page number should be greater than or equal to 0");

        if (pageSize.HasValue && pageSize.Value < 0)
            throw new ArgumentException("Page size should be greater than or equal to 0");

        return pageSize.HasValue ? source.Skip((page - 1) * pageSize.Value).Take(pageSize.Value) : source;
    }

    /// <summary>
    ///     Selects random element from the collection.
    /// </summary>
    /// <returns>Random element from the collection, if collection contains any elements. Otherwise, default value.</returns>
    public static TSource Random<TSource>(this IEnumerable<TSource> source)
    {
        if (!source.Any()) return default;

        var rnd = new Random(DateTime.Now.Millisecond);
        var index = rnd.Next(source.Count());

        return source.ElementAt(index);
    }

    public static T GetById<T>(this IEnumerable<T> source, object id)
        where T : IHaveId
    {
        return source.SingleOrDefault(el => el.Id == id);
    }

    public static IEnumerable<TSource> DistinctBy<TSource, TProperty, TOrderProperty>(
        this IEnumerable<TSource> source, Func<TSource, TProperty> property,
        Func<TSource, TOrderProperty> orderProperty, bool descending = false)
    {
        return source.GroupBy(property).Select(i =>
        {
            var ordered = descending ? i.OrderByDescending(orderProperty) : i.OrderBy(orderProperty);

            return ordered.First();
        });
    }

    public static bool IsSequential<TSource>(this IEnumerable<TSource> source, Func<TSource, int> property,
        int startIndex = 1)
    {
        var list = source.OrderBy(property).ToList();

        for (var i = 0; i < list.Count; ++i)
            if (property(list[i]) != (i + startIndex))
                return false;

        return true;
    }

    public static void MoveUpPosition<T>(this IEnumerable<T> collection, T item) where T : IOrderable
    {
        var orderedCollection = collection.OrderBy(el => el.Position).ToList();

        var indexOfCurrentElement = orderedCollection.IndexOf(item);

        if (indexOfCurrentElement == -1 || indexOfCurrentElement == 0)
            return;

        orderedCollection.SwapWithPositions(indexOfCurrentElement, indexOfCurrentElement - 1);
    }

    public static void MoveDownPosition<T>(this IEnumerable<T> collection, T item) where T : IOrderable
    {
        var orderedCollection = collection.OrderBy(el => el.Position).ToList();

        var indexOfCurrentElement = orderedCollection.IndexOf(item);

        if (indexOfCurrentElement == -1 || indexOfCurrentElement == orderedCollection.Count)
            return;

        orderedCollection.SwapWithPositions(indexOfCurrentElement, indexOfCurrentElement + 1);
    }

    public static IEnumerable<T> MoveToPosition<T>(this IEnumerable<T> collection, T item, int position)
        where T : IOrderable
    {
        collection = collection.OrderBy(x => x.Position);
        item.Position = -1;

        var index = 1;
        collection.Where(x => x.Position > 0).Take(position - 1).ForEach(x => x.Position = index++);

        index = position + 1;
        collection.Where(x => x.Position >= position).ForEach(x => x.Position = index++);

        item.Position = position;

        return collection.OrderBy(x => x.Position).ToList();
    }
}