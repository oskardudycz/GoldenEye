using System.Collections.Generic;
using GoldenEye.Core.Objects.General;

namespace GoldenEye.Core.Extensions.Collections
{
    public static class CollectionExtensions
    {
        public static bool RemoveById<T>(this ICollection<T> source, object id)
            where T : IHaveId
        {
            var elementToRemove = source.GetById(id);

            return source.Remove(elementToRemove);
        }
    }
}
