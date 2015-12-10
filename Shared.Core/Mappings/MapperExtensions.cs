using System.Linq;
using AutoMapper;

namespace GoldenEye.Shared.Core.Mappings
{
    public static class MapperExtensions
    {
        public static IMappingExpression<Source, Destination>
            IgnoreNonExistingProperties<Source, Destination>(this IMappingExpression<Source, Destination> expression)
            where Source : class
            where Destination : class
        {
            var sourceProperties = (typeof(Source)).GetProperties().ToList();
            var destinationProperties = (typeof(Destination)).GetProperties().ToList();


            foreach (var property in destinationProperties)
            {
                if (!sourceProperties.Exists(x => (x.Name == property.Name && x.PropertyType == property.PropertyType)))
                {
                    expression = expression.ForMember(property.Name, opt => opt.Ignore());
                }
            }

            return expression;
        }

    }
}