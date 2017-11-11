using System;
using System.Collections;
using System.Linq;
using System.Linq.Expressions;
using AutoMapper.QueryableExtensions;

namespace GoldenEye.Shared.Core.Mappings
{
    public static class MapperExtensions
    {
        public static IQueryable<TDestination> ProjectTo<TDestination>(this IList source,
            params Expression<Func<TDestination, object>>[] membersToExpand)
        {
            return source.AsQueryable().ProjectTo(membersToExpand);
        }
    }
}