using System;
using System.Resources;
using GoldenEye.Shared.Core.Resources;

namespace GoldenEye.Shared.Core.Extensions.Basic
{
    public static class BooleanExtensions
    {
        public static string DisplayName(this bool boolValue)
        {
            var resourceManager = new ResourceManager(typeof(CommonResources));
            var booleanValueName = string.Empty;

            try
            {
                var resourceName = resourceManager.GetString("Boolean_" + boolValue.ToString());
                if (string.IsNullOrEmpty(resourceName))
                {
                    return booleanValueName;
                }

                return resourceName;
            }
            catch (Exception)
            {
                return booleanValueName;
            }
        }
    }
}