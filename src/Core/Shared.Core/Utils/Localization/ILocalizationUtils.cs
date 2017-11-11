using System;
using System.Resources;

namespace GoldenEye.Shared.Core.Utils.Localization
{
    public interface ILocalizationUtils
    {
        string LookupResource(Type resourceManagerProvider, string resourceKey, params object[] formatParams);
        string LookupResource<T>(string resourceKey, params object[] formatParams);
        string LookupResource(ResourceQualifiedKey resourceQualifiedKey, params object[] formatParams);
        ResourceManager GetResourceManager(Type resourceManagerProvider);
    }
}
