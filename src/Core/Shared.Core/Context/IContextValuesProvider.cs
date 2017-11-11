using System.Collections.Generic;

namespace GoldenEye.Shared.Core.Context
{
    public interface IContextValuesProvider
    {
        IDictionary<string, object> Values { get; }
    }
}
