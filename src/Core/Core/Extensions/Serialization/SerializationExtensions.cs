﻿using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace GoldenEye.Extensions.Serialization;

public static class SerializationExtensions
{
    /// <summary>
    ///     Deserialize object from json with JsonNet
    /// </summary>
    /// <typeparam name="T">Type of the deserialized object</typeparam>
    /// <param name="json">json string</param>
    /// <returns>deserialized object</returns>
    public static T FromJson<T>(this string json)
    {
        return JsonConvert.DeserializeObject<T>(json);
    }

    /// <summary>
    ///     Serialize object to json with JsonNet
    /// </summary>
    /// <param name="obj">object to serialize</param>
    /// <returns>json string</returns>
    public static string ToJson(this object obj)
    {
        return JsonConvert.SerializeObject(obj);
    }

    /// <summary>
    ///     Serialize object to json with JsonNet
    /// </summary>
    /// <param name="obj">object to serialize</param>
    /// <returns>json string</returns>
    public static StringContent ToJsonStringContent(this object obj)
    {
        return new StringContent(obj.ToJson(), Encoding.UTF8, "application/json");
    }

    /// <summary>
    ///     Deserialize object from json with JsonNet
    /// </summary>
    /// <typeparam name="T">Type of the deserialized object</typeparam>
    /// <param name="json">json string</param>
    /// <returns>deserialized object</returns>
    public static async Task<T> FromJsonStringContentAsync<T>(this HttpContent content)
    {
        var json = await content.ReadAsStringAsync();
        return json.FromJson<T>();
    }
}