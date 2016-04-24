using System.Collections.Generic;
using System.Dynamic;

namespace GoldenEye.Shared.Core.Extensions.Dynamic
{
    public static class DynamicExtensions
    {
        public static dynamic ToExpando(this object value)
        {
            IDictionary<string, object> expando = new ExpandoObject();

            foreach (var property in value.GetType().GetProperties())
                expando.Add(property.Name, property.GetValue(value, null));

            return expando as ExpandoObject;
        }
    }
}
