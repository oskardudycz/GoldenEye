using System.Collections.Generic;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Shared.Core.Extensions.Collections
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
