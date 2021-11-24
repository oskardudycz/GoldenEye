using System.Collections;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;

namespace GoldenEye.Extensions.Collections;

public static class DictionaryExtensions
{
    /// <summary>
    ///     Extension method that turns a dictionary of string and object to an ExpandoObject
    ///     Snagged from http://theburningmonk.com/2011/05/idictionarystring-object-to-expandoobject-extension-method/
    /// </summary>
    public static ExpandoObject ToExpando(this IDictionary<string, object> dictionary)
    {
        var expando = new ExpandoObject();
        var expandoDic = (IDictionary<string, object>)expando;

        // go through the items in the dictionary and copy over the key value pairs)
        foreach (var kvp in dictionary)
            // if the value can also be turned into an ExpandoObject, then do it!
            if (kvp.Value is IDictionary<string, object>)
            {
                var expandoValue = ((IDictionary<string, object>)kvp.Value).ToExpando();
                expandoDic.Add(kvp.Key, expandoValue);
            }
            else if (kvp.Value is ICollection)
            {
                // iterate through the collection and convert any strin-object dictionaries
                // along the way into expando objects
                var itemList = new List<object>();
                foreach (var item in (ICollection)kvp.Value)
                    if (item is IDictionary<string, object>)
                    {
                        var expandoItem = ((IDictionary<string, object>)item).ToExpando();
                        itemList.Add(expandoItem);
                    }
                    else
                    {
                        itemList.Add(item);
                    }

                expandoDic.Add(kvp.Key, itemList);
            }
            else
            {
                expandoDic.Add(kvp);
            }

        return expando;
    }

    /// <summary>
    /// </summary>
    /// <typeparam name="T1"></typeparam>
    /// <typeparam name="T2"></typeparam>
    /// <param name="part1"></param>
    /// <param name="part2">Allows null - return part1 in case of part2 being null</param>
    /// <returns></returns>
    public static IDictionary<T1, T2> Merge<T1, T2>(this IDictionary<T1, T2> part1, IDictionary<T1, T2> part2)
    {
        return null == part2 ? part1 : part1.Union(part2).ToDictionary(x => x.Key, y => y.Value);
    }

    public static IDictionary<T1, T2> With<T1, T2>(this IDictionary<T1, T2> dictionary, T1 key, T2 value)
    {
        if (dictionary == null)
            dictionary = new Dictionary<T1, T2>();

        dictionary.Add(key, value);

        return dictionary;
    }

    public static IDictionary<T1, T2> AddOrReplace<T1, T2>(this IDictionary<T1, T2> dictionary, T1 key, T2 value)
    {
        if (!dictionary.ContainsKey(key))
            dictionary.Add(key, value);
        else
            dictionary[key] = value;

        return dictionary;
    }

    public static T2 GetValueOrDefault<T1, T2>(this IDictionary<T1, T2> dictionary, T1 key,
        T2 defaultValue = default)
    {
        return dictionary.ContainsKey(key) ? dictionary[key] : defaultValue;
    }
}