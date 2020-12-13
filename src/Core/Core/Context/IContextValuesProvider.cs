using System.Collections.Generic;

namespace GoldenEye.Core.Context
{
    public interface IContextValuesProvider
    {
        IDictionary<string, object> Values { get; }
    }
}
