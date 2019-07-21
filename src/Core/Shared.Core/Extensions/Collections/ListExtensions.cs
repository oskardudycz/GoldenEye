using System;
using System.Collections.Generic;
using GoldenEye.Shared.Core.Objects.Order;

namespace GoldenEye.Shared.Core.Extensions.Collections
{
    public static class ListExtensions
    {
        public static IList<T> Swap<T>(this IList<T> list, int indexA, int indexB)
        {
            T tmp = list[indexA];
            list[indexA] = list[indexB];
            list[indexB] = tmp;
            return list;
        }

        public static IList<T> SwapWithPositions<T>(this IList<T> list, int indexA, int indexB) where T : IOrderable
        {
            var tempPosition = list[indexA].Position;

            list[indexA].Position = list[indexB].Position;
            list[indexB].Position = tempPosition;

            list.Swap(indexA, indexB);
            return list;
        }

        public static IList<T> Replace<T>(this IList<T> list, T itemToReplace, T replacement)
        {
            var index = list.IndexOf(itemToReplace);
            if (index < 0)
            {
                throw new ArgumentOutOfRangeException("itemToReplace", "The element was not found in the list");
                //TODO: Add localized string
            }

            list.RemoveAt(index);
            list.Insert(index, replacement);

            return list;
        }

        /// <summary>
        /// Iterates backwards through the collection and performs specified action on each element.
        /// </summary>
        /// <param name="action">Action to perform on every element of the collection.</param>
        public static void ForEachBackwards<T>(this IList<T> list, Action<T> action)
        {
            for (int i = list.Count - 1; i >= 0; --i)
            {
                action(list[i]);
            }
        }

        internal static IList<T> ForEach<T>(this IList<T> list, Action<T> action)
        {
            for (int i = 0; i < list.Count; ++i)
            {
                action(list[i]);
            }

            return list;
        }

        public static IList<T> ForEach<T>(this IList<T> list, Action<T, int> actionWithIndex)
        {
            for (int i = 0; i < list.Count; ++i)
            {
                actionWithIndex(list[i], i);
            }

            return list;
        }
    }
}
