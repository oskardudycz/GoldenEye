using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace GoldenEye.Extensions.Basic;

public static class StringExtensions
{
    private const int DefaultLimit = 50;

    public static string Limit(this string text)
    {
        return text.Limit(DefaultLimit);
    }

    public static string Limit(this string text, int limit)
    {
        if (text.Length <= limit) return text;

        return string.Format("{0}...", text.Substring(0, limit));
    }

    public static string TrimStringToDemandedLength(this string message, int length)
    {
        return Limit(message, length);
    }

    public static bool IsNullOrEmpty(this string str)
    {
        return string.IsNullOrEmpty(str);
    }

    public static bool IsNullOrWhiteSpace(this string str)
    {
        return string.IsNullOrWhiteSpace(str);
    }

    public static List<string> SplitWithQuotes(this string str, char separator)
    {
        var foundParts = new List<string>();
        var openedQuotes = false;
        var lastPart = 0;

        for (var i = 0; i < str.Length; ++i)
            if (str[i] == separator && !openedQuotes)
            {
                foundParts.Add(str.Substring(lastPart, i - lastPart).Replace("\"", string.Empty));
                lastPart = i + 1;
            }
            else if (str[i] == '"')
            {
                openedQuotes = !openedQuotes;
            }

        foundParts.Add(str.Substring(lastPart).Replace("\"", string.Empty));

        return foundParts;
    }

    public static string IfEmpty(this string str, string defaultString)
    {
        return str.IsNullOrWhiteSpace() ? defaultString : str;
    }

    public static string AttachIfTrue(this string str, bool doAttach)
    {
        return doAttach ? str : string.Empty;
    }

    /// <summary>
    ///     Returns a substring, starting from specified text (included in resulting string);
    /// </summary>
    /// <param name="str"></param>
    /// <param name="needle">Text to be used as starting point.</param>
    public static string Substring(this string str, string needle)
    {
        return str.Substring(needle, StringComparison.CurrentCulture);
    }

    /// <summary>
    ///     Returns a substring, starting from specified text (included in resulting string);
    /// </summary>
    /// <param name="str"></param>
    /// <param name="needle">Text to be used as starting point.</param>
    public static string Substring(this string str, string needle, StringComparison comparisonType)
    {
        var needlePosition = str.IndexOf(needle, comparisonType);
        if (needlePosition < 0)
            throw new ArgumentException(string.Format("Needle ({0}) not found in the source string ({1}).", needle,
                str));

        return str.Substring(needlePosition);
    }

    public static Stream ToStream(this string str)
    {
        var stream = new MemoryStream();
        var writer = new StreamWriter(stream);
        writer.Write(str);
        writer.Flush();
        stream.Position = 0;
        return stream;
    }

    public static string ToUpperFirstLetter(this string source)
    {
        return source.ChangeFirstLetter(SizeChangeEnum.Upper);
    }

    public static string ToLowerFirstLetter(this string source)
    {
        return source.ChangeFirstLetter(SizeChangeEnum.Lower);
    }

    private static string ChangeFirstLetter(this string source, SizeChangeEnum sizeChangeEnum)
    {
        if (string.IsNullOrEmpty(source))
            return string.Empty;
        // convert to char array of the string
        var letters = source.ToCharArray();
        // upper case the first char

        switch (sizeChangeEnum)
        {
            case SizeChangeEnum.Upper:
                letters[0] = char.ToUpper(letters[0]);
                break;

            case SizeChangeEnum.Lower:
                letters[0] = char.ToLower(letters[0]);
                break;

            default:
                throw new ArgumentOutOfRangeException("sizeChangeEnum");
        }

        // return the array made of the new char array
        return new string(letters);
    }

    public static string GetStringBetween(this string str, string start, string end)
    {
        var dataSourceTokenIndex = str.IndexOf(start, StringComparison.Ordinal) + start.Length + 1;
        var dataSourcePartLength =
            str.IndexOf(end, dataSourceTokenIndex, StringComparison.Ordinal) - dataSourceTokenIndex;

        return str.Substring(dataSourceTokenIndex, dataSourcePartLength);
    }

    public static string Random(int size)
    {
        var builder = new StringBuilder();
        var random = new Random();
        for (var i = 0; i < size; i++)
        {
            var ch = Convert.ToChar(Convert.ToInt32(Math.Floor(26 * random.NextDouble() + 65)));
            builder.Append(ch);
        }

        return builder.ToString();
    }

    public static string[] SplitCamelCase(this string source)
    {
        return Regex.Split(source, @"(?<!^)(?=[A-Z])");
    }

    public static string ToReadableTypeName<T>()
    {
        return string.Join(" ", typeof(T).Name.SplitCamelCase());
    }

    private enum SizeChangeEnum
    {
        Upper,
        Lower
    }
}