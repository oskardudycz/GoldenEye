using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;

namespace GoldenEye.Utils.Collections;

/// <summary>
///     Converts any collection to comma seperated values stream or string based on collection objects properties values
/// </summary>
/// <typeparam name="T"></typeparam>
public static class CollectionToCSVConverter<T>
{
    public static string GetCsvString(ICollection<T> collection, string separator = ",",
        string[] customHeaders = null, bool headers = false)
    {
        var result = new StringBuilder();

        if (headers)
            result.AppendLine(customHeaders != null
                ? ProcessHeaders(customHeaders, separator)
                : GetHeaders(separator));

        foreach (var item in collection) result.AppendLine(ProcessItem(item, separator));

        return result.ToString();
    }

    public static Stream GetCsvStream(ICollection<T> collection, string separator = ",",
        string[] customHeaders = null, bool headers = false)
    {
        var sw = new StreamWriter(new MemoryStream());

        if (collection.Count == 0)
            return sw.BaseStream;

        if (headers)
            sw.WriteLine(customHeaders != null
                ? ProcessHeaders(customHeaders, separator)
                : GetHeaders(separator));

        foreach (var item in collection) sw.WriteLine(ProcessItem(item, separator));

        sw.Flush();
        sw.BaseStream.Position = 0;

        return sw.BaseStream;
    }

    private static string ProcessItem(T item, string separator)
    {
        var result = string.Empty;

        foreach (var prop in typeof(T).GetTypeInfo().GetProperties())
        {
            var value = prop.PropertyType.GetTypeInfo().IsEnum
                ? ((Enum)prop.GetValue(item, null)).ToString("G")
                : prop.GetValue(item, null).ToString();
            var format = value.Contains(",") ? "\"{0}\"{1}" : "{0}{1}";
            result += string.Format(format, value, separator);
        }

        result = result.Remove(result.Length - 1);

        return result;
    }

    private static string ProcessHeaders(IEnumerable<string> headers, string separator)
    {
        var result = headers.Aggregate(string.Empty,
            (current, item) => current + string.Format("{0}{1}", item, separator));

        result = result.Remove(result.Length - 1);

        return result;
    }

    private static string GetHeaders(string separator)
    {
        var result = typeof(T).GetProperties()
            .Aggregate(string.Empty, (current, prop) => current + string.Format("{0}{1}", prop.Name, separator));

        result = result.Remove(result.Length - 1);

        return result;
    }
}