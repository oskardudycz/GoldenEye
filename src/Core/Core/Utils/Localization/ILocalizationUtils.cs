using System;
using System.Resources;

namespace GoldenEye.Utils.Localization;

public interface ILocalizationUtils
{
    string LookupResource(Type resourceManagerProvider, string resourceKey, params object[] formatParams);

    string LookupResource<T>(string resourceKey, params object[] formatParams);

    string LookupResource(ResourceQualifiedKey resourceQualifiedKey, params object[] formatParams);

    ResourceManager GetResourceManager(Type resourceManagerProvider);
}