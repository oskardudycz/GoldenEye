using System;

namespace Shared.Core.Extensions
{
    public static class DateTimeExtensions
    {
        public static string ToUTCTime(this DateTime dateTime)
        {
            return dateTime.ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
        }
    }
}