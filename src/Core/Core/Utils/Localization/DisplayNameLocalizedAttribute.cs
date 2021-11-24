using System;
using System.ComponentModel;

namespace GoldenEye.Utils.Localization;

[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method | AttributeTargets.Property |
                AttributeTargets.Event)]
public class DisplayNameLocalizedAttribute: DisplayNameAttribute
{
    //public DisplayNameLocalizedAttribute(Type resourceManagerProvider, string resourceKey)
    //    : base(LocalizationUtils.Instance.LookupResource(resourceManagerProvider, resourceKey))
    //{
    //}
}