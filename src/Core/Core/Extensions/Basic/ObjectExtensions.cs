using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using GoldenEye.Extensions.Lambda;
using GoldenEye.Extensions.Reflection;

namespace GoldenEye.Extensions.Basic;

public static class ObjectExtensions
{
    private static readonly Type[] EmptyTypes = { };

    public static T? As<T>(this object? obj)
    {
        var type = typeof(T);
        var underlyingType = Nullable.GetUnderlyingType(type);
        var isNullable = underlyingType != null;
        var realType = underlyingType ?? type;

        switch (obj)
        {
            case null when !isNullable && !type.GetTypeInfo().IsClass:
                throw new InvalidCastException("Cannot assign null to non-reference type");
            case null:
                return default;
        }

        if (!realType.GetTypeInfo().IsEnum) return (T)obj;

        if (!realType.IsEnumDefined(obj))
        {
            throw new ArgumentOutOfRangeException(nameof(obj));
        }
        return (T)Enum.ToObject(realType, obj);
    }

    public static T? ConvertTo<T>(this object? obj)
    {
        var result = ConvertTo(obj, typeof(T));

        if (result == default)
            return default;

        return (T)result;
    }

    public static object? ConvertTo(this object? obj, Type t)
    {
        if (obj == null)
            return GetDefault(t);

        var u = Nullable.GetUnderlyingType(t);

        return Convert.ChangeType(obj, u ?? t, CultureInfo.CurrentCulture);
    }

    public static bool Is<T>(this object obj)
    {
        return obj is T;
    }

    public static T? GetDefault<T>()
    {
        var result = GetDefault(typeof(T));

        if (result == default)
            return default;

        return (T)result;
    }

    public static T? GetEmpty<T>()
    {
        if (typeof(T) == typeof(string))
            return (T)(object)string.Empty;

        return default;
    }

    public static object? GetDefault(Type type, object? defaultValue = null)
    {
        return type.GetTypeInfo().IsValueType ? Activator.CreateInstance(type) : defaultValue;
    }

    public static T? CreateOrDefault<T>()
    {
        var result = CreateOrDefault(typeof(T));
        var defaultValue = default(T);

        if (Equals(result, defaultValue))
            return defaultValue;

        if (result == default)
            return default;

        return (T)result;
    }

    public static object? CreateOrDefault(Type type)
    {
        return (type.GetConstructor(EmptyTypes) != null) ? Activator.CreateInstance(type) : GetDefault(type);
    }

    public static object? GetValue(this object obj, string propertyName, object? defaultValue = null)
    {
        var type = obj.GetType();
        var property = ReflectionExtensions.GetProperty(type, propertyName);
        if (property == null)
            return defaultValue;

        return property.GetValue(obj, null);
    }

    public static TProp GetValue<T, TProp>(this T obj, Expression<Func<T, TProp>> expression)
    {
        var getter = expression.Compile();

        return getter(obj);
    }

    public static object GetDefaultValue(this object obj, string propertyName)
    {
        var type = obj.GetType();
        var property = ReflectionExtensions.GetProperty(type, propertyName);

        return GetDefault(property.PropertyType);
    }

    public static void SetValue(this object obj, string propertyName, object value)
    {
        var type = obj.GetType();
        var property = ReflectionExtensions.GetProperty(type, propertyName);

        property.SetValue(obj, value, null);
    }

    public static void SetValue<T, TProp>(this T obj, Expression<Func<T, TProp>> expression, TProp value)
    {
        var setter = expression.Setter();

        setter(obj, value);
    }

    public static void ClearValue(this object obj, string propertyName)
    {
        var type = obj.GetType();
        var property = ReflectionExtensions.GetProperty(type, propertyName);

        property.SetValue(obj, GetDefault(property.PropertyType), null);
    }

    public static TProp GetValue<T, TProp>(this T obj, string propertyName)
    {
        var val = ReflectionExtensions.GetProperty(typeof(T), propertyName).GetValue(obj, null);
        var defaultValue = GetDefault<TProp>();

        if (Equals(val, defaultValue))
            return GetDefault<TProp>();

        return (TProp)val;
    }

    public static string ObjectToString(object value)
    {
        return value == null ? string.Empty : value.ToString();
    }

    public static IDictionary<string, object> AsDictionary(this object source,
        BindingFlags bindingAttr = BindingFlags.DeclaredOnly | BindingFlags.Public | BindingFlags.Instance)
    {
        return ReflectionExtensions.GetProperties(source.GetType(), bindingAttr).ToDictionary
        (
            propInfo => propInfo.Key,
            propInfo => propInfo.Value.GetValue(source, null)
        );
    }

    public static bool In<T>(this T t, params T[] collection)
    {
        return collection.ToList().Contains(t);
    }

    /// <summary>
    ///     Modifies object using specified action.
    /// </summary>
    /// <param name="obj"></param>
    /// <param name="action">Action to be performed.</param>
    /// <param name="throwExceptionIfNull"></param>
    /// <returns>Modified object, if object is not null. Otherwise, throws exception</returns>
    public static T Modify<T>(this T obj, Action<T> action, bool throwExceptionIfNull = false)
    {
        if (!Equals(obj, default(T)))
            action(obj);
        else if (throwExceptionIfNull) throw new ArgumentNullException();

        return obj;
    }

    public static TOut As<TIn, TOut>(this TIn obj, Func<TIn, TOut> func)
    {
        if (Equals(obj, default(TIn))) throw new ArgumentNullException();

        return func(obj);
    }

    /// <summary>
    ///     Generates a list with one element.
    /// </summary>
    /// <returns>New list with one element.</returns>
    public static List<T> AsList<T>(this T obj)
    {
        return new List<T> {obj};
    }

    public static bool IsNumber(this object value)
    {
        return value is sbyte or byte or short or ushort or int or uint or long or ulong or float or double or decimal;
    }

    public static object Invoke<T>(this Type type, T obj, string methodName, params object[] parameters)
    {
        var method = type.GetMethod(methodName);
        return method.Invoke(obj, parameters);
    }

    public static object InvokeGeneric<T>(this Type type, T obj, string methodName, Type[] types,
        params object[] parameters)
    {
        var method = type.GetMethod(methodName);
        var generic = method.MakeGenericMethod(types);
        return generic.Invoke(obj, parameters);
    }

    public static object InvokeGeneric<T>(T obj, string methodName, Type[] types, params object[] parameters)
    {
        var method = typeof(T).GetMethod(methodName);
        var generic = method.MakeGenericMethod(types);
        return generic.Invoke(obj, parameters);
    }
}
