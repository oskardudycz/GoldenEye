using System;

namespace Shared.Core.Extensions
{
    public static class StringExtensions
    {
        public static string GetStringBetween(this string str, string start, string end)
        {
            var dataSourceTokenIndex = str.IndexOf(start, StringComparison.Ordinal) + start.Length + 1;
            var dataSourcePartLength = str.IndexOf(end, dataSourceTokenIndex, StringComparison.Ordinal) - dataSourceTokenIndex;

            return str.Substring(dataSourceTokenIndex, dataSourcePartLength);
        }
    }
}