using System;
using System.Collections.Generic;
using System.Linq;

namespace GoldenEye.Extensions.Enums;

public static class EnumExtensions
{
    public static IList<TEnum> GetAllValues<TEnum>()
    {
        return Enum.GetValues(typeof(TEnum)).Cast<TEnum>().ToList();
    }

    public static TEnum Parse<TEnum>(string enumText)
    {
        return (TEnum)Enum.Parse(typeof(TEnum), enumText, false);
    }

    //public static string DisplayName(this Enum enumValue)
    //{
    //    return DisplayName<Enum>(enumValue);
    //}

    //public static string DisplayName<TEnum, TResources>(this TEnum enumValue)
    //{
    //    if (!typeof(TEnum).IsEnum)
    //        throw new InvalidOperationException("Type argument TEnum must be an enum.");

    //    var enumTypeName = enumValue.GetType().Name;
    //    var enumValueName = enumValue.ToString();

    //    if (enumTypeName.EndsWith("Enum"))
    //    {
    //        enumTypeName = enumTypeName.Substring(0, enumTypeName.Length - 4);
    //    }

    //    var resourceManager = new ResourceManager(typeof(EnumResources));

    //    try
    //    {
    //        var resourceName = resourceManager.GetString("Enum_" + enumTypeName + "_" + enumValueName);
    //        if (string.IsNullOrEmpty(resourceName))
    //        {
    //            return enumValueName;
    //        }

    //        return resourceName;
    //    }
    //    catch (Exception)
    //    {
    //        return enumValueName;
    //    }
    //}

    //public static IEnumerable<LocalizedEnum<TEnum>> ToLocalizedCollection<TEnum>()
    //{
    //    if (!typeof(TEnum).IsEnum)
    //        throw new InvalidOperationException("Type argument TEnum must be an enum.");

    //    var allValues = GetAllValues<TEnum>();

    //    return allValues.Select(i => LocalizedEnum.Create(i));
    //}
}