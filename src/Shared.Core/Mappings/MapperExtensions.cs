using System;
using System.Linq;
using AutoMapper;

namespace GoldenEye.Shared.Core.Mappings
{
    public static class MapperExtensions
    {
        public static IMappingExpression IgnoreNonExistingProperties(
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

        public static IMappingExpression<TSource, TDestination> IgnoreNonExistingProperties<TSource, TDestination>(
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

    }
}