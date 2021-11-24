using System;
using System.Collections.Generic;

namespace GoldenEye.Extensions.Collections;

public static class ArrayExtensions
{
    public static IReadOnlyCollection<T> AsReadOnly<T>(this T[] array) => Array.AsReadOnly(array);
}