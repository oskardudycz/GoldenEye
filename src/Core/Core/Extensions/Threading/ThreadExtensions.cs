using System;
using System.Globalization;
using System.Threading;

namespace GoldenEye.Extensions.Threading;

public static class ThreadExtensions
{
    public static T WithUiCulture<T>(this Thread currentThread, string culture, Func<T> doAction)
    {
        var currentUiCulture = currentThread.CurrentUICulture;

        currentThread.CurrentUICulture = new CultureInfo(culture);

        T returnValue = doAction();

        currentThread.CurrentUICulture = currentUiCulture;

        return returnValue;
    }
}