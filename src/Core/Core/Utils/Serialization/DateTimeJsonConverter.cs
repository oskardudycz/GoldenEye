using System;
using Newtonsoft.Json;

namespace GoldenEye.Utils.Serialization;

public class DateTimeJsonConverter: JsonConverter
{
    public override bool CanRead
    {
        get { return false; }
    }

    public static DateTimeJsonConverter Get()
    {
        return new DateTimeJsonConverter();
    }

    public override void WriteJson(JsonWriter writer, object value, Newtonsoft.Json.JsonSerializer serializer)
    {
        writer.WriteRawValue(string.Format("new Date('{0}')", value));
    }

    public override object ReadJson(JsonReader reader, Type objectType, object existingValue,
        Newtonsoft.Json.JsonSerializer serializer)
    {
        throw new NotImplementedException(
            "Unnecessary because CanRead is false. The type will skip the converter.");
    }

    public override bool CanConvert(Type objectType)
    {
        return objectType == typeof(DateTime);
    }
}