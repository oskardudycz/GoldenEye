using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using GoldenEye.Extensions.Basic;
using GoldenEye.Modules.Attributes;
using GoldenEye.Utils.Assemblies;

namespace GoldenEye.Extensions.Reflection;

public static class ReflectionExtensions
{
    private static readonly object _lock = new object();

    public static Dictionary<Type, Dictionary<string, PropertyInfo>> TypeProperties =
        new Dictionary<Type, Dictionary<string, PropertyInfo>>();

    private static IList<Assembly> _assemblies;

    public static IEnumerable<Assembly> Assemblies
    {
        get { return _assemblies ?? (_assemblies = AssembliesProvider.GetAll().ToList()); }
    }

    public static bool HasProperty(this Type type, string propertyName)
    {
        return GetProperty(type, propertyName) != null;
    }

    public static PropertyInfo GetProperty(Type type, string propertyName)
    {
        lock (_lock)
        {
            if (!TypeProperties.ContainsKey(type))
                TypeProperties.Add(type, type.GetProperties().ToDictionary(ks => ks.Name, vs => vs));
        }

        return TypeProperties[type].ContainsKey(propertyName) ? TypeProperties[type][propertyName] : null;
    }

    public static IDictionary<string, PropertyInfo> GetProperties(Type type)
    {
        lock (_lock)
        {
            if (!TypeProperties.ContainsKey(type))
                TypeProperties.Add(type, type.GetProperties().ToDictionary(ks => ks.Name, vs => vs));
        }

        return TypeProperties[type];
    }

    public static IDictionary<string, PropertyInfo> GetProperties(Type type, BindingFlags bindingAttr)
    {
        lock (_lock)
        {
            if (!TypeProperties.ContainsKey(type))
                TypeProperties.Add(type, type.GetProperties(bindingAttr).ToDictionary(ks => ks.Name, vs => vs));
        }

        return TypeProperties[type];
    }

    public static Type GetPropertyType(this Type type, string propertyName)
    {
        lock (_lock)
        {
            if (!TypeProperties.ContainsKey(type))
                TypeProperties.Add(type, type.GetProperties().ToDictionary(ks => ks.Name, vs => vs));
        }

        return GetProperties(type)[propertyName].PropertyType;
    }

    public static bool Implements<T>(this Type type)
    {
        return type.GetInterfaces().Contains(typeof(T));
    }

    public static object InvokeStaticGeneric(this Type type, string methodName, Type[] types,
        params object[] parameters)
    {
        return InvokeStaticGeneric(type, methodName, types, null, parameters);
    }

    public static object InvokeStaticGeneric(this Type type, string methodName, Type[] types,
        Type[] methodParameterTypes, params object[] parameters)
    {
        var method = methodParameterTypes == null
            ? type.GetMethod(methodName)
            : type.GetMethod(methodName, methodParameterTypes);
        var generic = method.MakeGenericMethod(types);
        return generic.Invoke(null, parameters);
    }

    public static IEnumerable<PropertyInfo> GetAllInterfacesPropertiesWithAttribute<TAttribute>(this Type type)
        where TAttribute : Attribute
    {
        return type.GetInterfaces()
            .SelectMany(x => x.GetProperties())
            .Where(x => x.GetCustomAttributes(typeof(TAttribute), true).Count() != 0);
    }

    public static TAttribute GetAttribute<TAttribute>(this PropertyInfo propertyInfo)
        where TAttribute : Attribute
    {
        return propertyInfo.GetCustomAttributes(typeof(TAttribute), true).FirstOrDefault().CastTo<TAttribute>();
    }

    public static Type GetTypeFromAllAssemblies(string typeName)
    {
        if (!typeName.Contains("."))
            return
                Assemblies
                    .SelectMany(el => el.GetTypes())
                    .FirstOrDefault(el => el.Name == typeName);

        return Assemblies.Select(el => el.GetType(typeName)).FirstOrDefault(el => el != null);
    }

    public static IList<Type> GetTypesFromAllAssemblies(Func<Type, bool> selector)
    {
        return Assemblies
            .SelectMany(s => s.GetTypes())
            .Where(selector).ToList();
    }

    public static IList<Type> GetTypesFromAllProjectAssemblies(Func<Type, bool> selector = null)
    {
        var types = Assemblies
            .Where(el => el.GetCustomAttribute<ProjectAssemblyAttribute>() != null)
            .SelectMany(s => s.GetTypes()).ToList();

        return selector == null ? types : types.Where(selector).ToList();
    }

    public static IList<Assembly> GetProjectAssemblies()
    {
        return Assemblies.Where(el => el.GetCustomAttribute<ProjectAssemblyAttribute>() != null).ToList();
    }

    internal static T GetCustomAttribute<T>(this Assembly assembly) where T : Attribute
    {
        return assembly.GetCustomAttributes<T>().FirstOrDefault();
    }
}