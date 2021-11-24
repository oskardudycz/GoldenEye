using System;

namespace GoldenEye.Utils.Coding;

public class Switch
{
    public Switch(object o)
    {
        Object = o;
    }

    public object Object { get; }
}

/// <summary>
///     Extensions, because otherwise casing fails on Switch==null
/// </summary>
public static class SwitchExtensions
{
    public static Switch Case<T>(this Switch s, Action<T> a)
        where T : class
    {
        return Case(s, o => true, a, false);
    }

    public static Switch Case<T>(this Switch s, Action<T> a,
        bool fallThrough) where T : class
    {
        return Case(s, o => true, a, fallThrough);
    }

    public static Switch Case<T>(this Switch s,
        Func<T, bool> c, Action<T> a) where T : class
    {
        return Case(s, c, a, false);
    }

    public static Switch Case<T>(this Switch s,
        Func<T, bool> c, Action<T> a, bool fallThrough) where T : class
    {
        if (s == null) return null;

        var t = s.Object as T;
        if (t != null)
            if (c(t))
            {
                a(t);
                return fallThrough ? s : null;
            }

        return s;
    }
}