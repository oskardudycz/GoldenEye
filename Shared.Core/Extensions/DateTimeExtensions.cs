using System;

namespace GoldenEye.Shared.Core.Extensions
{
    public static class DateTimeExtensions
    {
        public static string ToUTCTime(this DateTime dateTime)
        {
            return dateTime.Truncate().ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
        }

        public static DateTime Truncate(this DateTime date, long resolution = TimeSpan.TicksPerMillisecond)
        {
            var ticks = (date.Ticks/resolution)*resolution;;

            var result = new DateTime(ticks, date.Kind);

            return result;
        }

        public static DateTime? Truncate(this DateTime? date, long resolution = TimeSpan.TicksPerMillisecond)
        {
            if (!date.HasValue)
                throw new ArgumentException("date");

            return date.Value.Truncate(resolution);
        }
    }
}