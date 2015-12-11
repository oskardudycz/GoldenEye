using System.Collections.Generic;
using System.Linq;
using GoldenEye.Shared.Core;

namespace System.Collections
{
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
            foreach (var element in list)
            {
                action(element);
            }
        }

        public static void ForEach<T>(this IEnumerable<T> list, Action<T, int> action)
        {
            int index = 0;
            foreach (var element in list)
            {
                action(element, index);
                index++;
            }
        }

        public static void ForEach(this IEnumerable list, Action<object> action)
        {
            foreach (var element in list)
            {
                action(element);
            }
        }

        public static IEnumerable<TResult> Select<T, TResult>(this IEnumerable<T> source,
            Func<T, int, TResult> projection)
        {
            int index = 0;
            using (var iterator = source.GetEnumerator())
            {
                if (!iterator.MoveNext())
                {
                    yield break;
                }
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
                if (!iterator.MoveNext())
                {
                    yield break;
                }
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
                if (!iterator.MoveNext())
                {
                    yield break;
                }
                TSource previous = iterator.Current;
                while (iterator.MoveNext())
                {
                    yield return projection(previous, iterator.Current);
                    previous = iterator.Current;
                }
            }
        }

        public static IEnumerable<TSource> Page<TSource>(this IEnumerable<TSource> source, int page, int? pageSize)
        {
            if (page < 0)
            {
                throw new ArgumentException("Page number should be greater than or equal to 0");
            }

            if (pageSize.HasValue && pageSize.Value < 0)
            {
                throw new ArgumentException("Page size should be greater than or equal to 0");
            }

            return (pageSize.HasValue == true) ? source.Skip((page - 1)*pageSize.Value).Take(pageSize.Value) : source;
        }

        /// <summary>
        /// Selects random element from the collection.
        /// </summary>
        /// <returns>Random element from the collection, if collection contains any elements. Otherwise, default value.</returns>
        public static TSource Random<TSource>(this IEnumerable<TSource> source)
        {
            if (!source.Any())
            {
                return default(TSource);
            }
            else
            {
                var rnd = new Random(DateTime.Now.Millisecond);
                var index = rnd.Next(source.Count());

                return source.ElementAt(index);
            }
        }

        public static T GetById<T>(this IEnumerable<T> source, int id)
            where T : IHasId
        {
            return source.SingleOrDefault(el => el.Id == id);
        }

        public static IEnumerable<TSource> DistinctBy<TSource, TProperty, TOrderProperty>(
            this IEnumerable<TSource> source, Func<TSource, TProperty> property,
            Func<TSource, TOrderProperty> orderProperty, bool descending = false)
        {
            return source.
                GroupBy(property).
                Select(i =>
                {
                    var ordered = descending ? i.OrderByDescending(orderProperty) : i.OrderBy(orderProperty);

                    return ordered.First();
                });
        }

        public static bool IsSequential<TSource>(this IEnumerable<TSource> source, Func<TSource, int> property,
            int startIndex = 1)
        {
            var list = source.OrderBy(property).ToList();

            return !list.Where((t, i) => property(t) != (i + startIndex)).Any();
        }
    }
}