using System;
using System.Linq;
using System.Reflection;
using System.Resources;

namespace GoldenEye.Shared.Core.Utils.Localization
{
    public class LocalizationUtils: ILocalizationUtils
    {
        public static readonly LocalizationUtils Instance = new LocalizationUtils();

        public string LookupResource(Type resourceManagerProvider, string resourceKey, params object[] formatParams)
        {
            var resourceManager = GetResourceManager(resourceManagerProvider);
            var resourceValue = resourceManager != null ? resourceManager.GetString(resourceKey) : null;

            return resourceValue != null ? string.Format(resourceValue, formatParams) : null;
        }

        public string LookupResource<T>(string resourceKey, params object[] formatParams)
        {
            return LookupResource(typeof(T), resourceKey, formatParams);
        }

        public string LookupResource(ResourceQualifiedKey resourceQualifiedKey, params object[] formatParams)
        {
            return LookupResource(resourceQualifiedKey.ResourceType, resourceQualifiedKey.ResourceId, formatParams);
        }

        public ResourceManager GetResourceManager(Type resourceManagerProvider)
        {
            var resourceManagerProperty =
                resourceManagerProvider
                    .GetProperties(BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public)
                    .FirstOrDefault(el => el.PropertyType == typeof(ResourceManager));

            if (resourceManagerProperty == null)
                return null;

            return (ResourceManager)resourceManagerProperty.GetValue(null, null);
        }
    }
}
