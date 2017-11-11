using System;
using System.Collections.Generic;
using System.Linq;
using AutoMapper;

namespace GoldenEye.Shared.Core.Extensions.Mapping
{
    public static class AutoMapperExtension
    {
        public static TEntity MapEntity<TDataContract, TEntity>(TDataContract source, TEntity destination)
        {
            return (TEntity)Mapper.Map(source, destination, typeof(TDataContract), typeof(TEntity));
        }

        public static TDataContract MapDataContract<TEntity, TDataContract>(TEntity source, TDataContract destination)
        {
            return (TDataContract)MapDataContract(source, destination, typeof(TEntity), typeof(TDataContract));
        }

        public static object MapDataContract(object source, object destination, Type entityType, Type dataContractType)
        {
            return Mapper.Map(source, destination, entityType, dataContractType);
        }

        public static TResult MapTo<TResult>(this object obj)
        {
            return (TResult)Mapper.Map(obj, obj.GetType(), typeof(TResult));
        }

        public static IList<TResult> MapListTo<T, TResult>(this IList<T> list)
        {
            return list.Select(el => el.MapTo<TResult>()).ToList();
        }

        public static object Map(this object @this, Type destinationType)
        {
            return Mapper.Map(@this, @this.GetType(), destinationType);
        }

        public static TDestination Map<TDestination>(this object @this)
        {
            if (@this == null)
            {
                return default(TDestination);
            }

            return (TDestination)@this.Map(typeof(TDestination));
        }

        public static TDestination Map<TSource, TDestination>(this TSource @this)
        {
            return Mapper.Map<TSource, TDestination>(@this);
        }

        public static TDestination MapFrom<TSource, TDestination>(this TDestination @this, TSource from)
        {
            return Mapper.Map(from, @this);
        }
    }
}