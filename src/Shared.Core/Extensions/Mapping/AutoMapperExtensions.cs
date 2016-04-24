using System;
using System.Collections.Generic;
using System.Linq;
using AutoMapper;
using GoldenEye.Shared.Core.Extensions.Reflection;

namespace GoldenEye.Shared.Core.Extensions.Mapping
{
    public static class AutoMapperExtension
    {
        public static IMappingExpression IgnoreAllNonExisting(
          this IMappingExpression expression, Type sourceType, Type destinationType)
        {
            var existingMaps = Mapper.GetAllTypeMaps().First(x => x.SourceType == sourceType
                                                                  && x.DestinationType == destinationType);

            foreach (var property in existingMaps.GetUnmappedPropertyNames())
            {
                expression.ForMember(property, opt => opt.Ignore());
            }
            return expression;
        }

        public static IMappingExpression<TSource, TDestination> IgnoreAllNonExisting<TSource, TDestination>(
          this IMappingExpression<TSource, TDestination> expression)
        {
            var sourceType = typeof(TSource);
            var destinationType = typeof(TDestination);
            var existingMaps = Mapper.GetAllTypeMaps().First(x => x.SourceType == sourceType
                                                                  && x.DestinationType == destinationType);

            foreach (var property in existingMaps.GetUnmappedPropertyNames())
            {
                expression.ForMember(property, opt => opt.Ignore());
            }
            return expression;
        }

        // TODO: finish implementing, some problems occured
        //public static IMappingExpression<TSource, TDestination> IgnoreAllNonExistingWithDefaults<TSource, TDestination>(
        //    this IMappingExpression<TSource, TDestination> expression)
        //{
        //    var sourceType = typeof(TSource);
        //    var destinationType = typeof(TDestination);
        //    var existingMaps = Mapper.GetAllTypeMaps().First(x => x.SourceType == sourceType
        //                                                          && x.DestinationType == destinationType);

        //    var defaultedTypes = new Type[] { typeof(Guid), typeof(DateTime), typeof(List<>) };

        //    var destinationTypeProperties = destinationType
        //        .GetInterfaces().SelectMany(x => x.GetProperties(BindingFlags.FlattenHierarchy | BindingFlags.Public | BindingFlags.Instance))
        //        .Union(destinationType.GetProperties(BindingFlags.FlattenHierarchy | BindingFlags.Public | BindingFlags.Instance));

        //    var unmappedProperties = existingMaps.GetUnmappedPropertyNames().ToDictionary(i => i, i => destinationTypeProperties.Single(x => x.Name == i).PropertyType);
        //    var defaultedProperties = unmappedProperties.Where(i => defaultedTypes.Contains(i.Value));

        //    foreach (var property in defaultedProperties)
        //    {
        //        expression.ForMember(property.Key, opt => opt.MapFrom(model => ObjectExtensions.GetDefault(property.Value, null)));
        //    }

        //    return IgnoreAllNonExisting(expression);
        //}

        public static IMappingExpression<TSource, TDestination> UseDestinationForAllNonExisting<TSource, TDestination>(
        this IMappingExpression<TSource, TDestination> expression)
        {
            var sourceType = typeof(TSource);
            var destinationType = typeof(TDestination);
            var existingMaps = Mapper.GetAllTypeMaps().First(x => x.SourceType == sourceType
                                                                  && x.DestinationType == destinationType);
            foreach (var property in existingMaps.GetUnmappedPropertyNames())
            {
                expression.ForMember(property, opt => opt.UseDestinationValue());
            }
            return expression;
        }

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

        public static void CreateMapsForSourceTypes(this IConfiguration configuration, Func<Type, bool> filter, Func<Type, Type> destinationType, Action<IMappingExpression, Type, Type> mappingConfiguration)
        {
            var typesInThisAssembly = ReflectionExtensions.GetTypesFromAllProjectAssemblies();
            CreateMapsForSourceTypes(configuration, typesInThisAssembly.Where(filter), destinationType, mappingConfiguration);
        }

        public static void CreateMapsForSourceTypes(this IConfiguration configuration, IEnumerable<Type> typeSource, Func<Type, Type> destinationType, Action<IMappingExpression, Type, Type> mappingConfiguration)
        {
            foreach (var type in typeSource)
            {
                var destType = destinationType(type);
                if (destType == null) continue;
                var mappingExpression = configuration.CreateMap(type, destType);

                mappingConfiguration(mappingExpression, type, destType);

                var mappingExpression2 = configuration.CreateMap(destType, type);
                mappingConfiguration(mappingExpression2, destType, type);
            }
        }
    }
}