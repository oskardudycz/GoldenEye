using System;
using System.Text;

namespace GoldenEye.Extensions.Basic;

public static class StringBuilderExtensions
{
    public static StringBuilder AppendDescriptionLine(this StringBuilder sb, EDescriptionGenerationInfo info,
        string msg)
    {
        switch (info)
        {
            case EDescriptionGenerationInfo.OneLine:
                sb.Append(msg);
                break;

            case EDescriptionGenerationInfo.MultiLine:
                sb.AppendLine(msg);
                break;

            case EDescriptionGenerationInfo.MultiLineHtml:
                sb.AppendLine(
                    string.Format("<p>{0}</p>", msg));
                break;

            default:
                throw new ArgumentOutOfRangeException("info", info, null);
        }

        return sb;
    }
}

public enum EDescriptionGenerationInfo
{
    OneLine,
    MultiLine,
    MultiLineHtml
}