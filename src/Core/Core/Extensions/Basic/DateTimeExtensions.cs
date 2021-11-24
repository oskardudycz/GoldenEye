using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using GoldenEye.Objects.Dates;

namespace GoldenEye.Extensions.Basic;

public static class DateTimeExtensions
{
    private static List<DateTime> _allDatesInCurrentYear;

    public static DateTime Today
    {
        get { return DateTime.Today; }
    }

    public static DateTime Tomorrow
    {
        get { return DateTime.Today.AddDays(1); }
    }

    public static DateTime Yesterday
    {
        get { return DateTime.Today.AddDays(-1); }
    }

    /// <summary>
    ///     All dates in current year
    /// </summary>
    public static List<DateTime> AllDatesInCurrentYear
    {
        get { return _allDatesInCurrentYear ??= GetDates(DateTime.Today.Year); }
    }

    /// <summary>
    ///     Checks, whether date falls in the range defined by <paramref name="rangeStart" /> and <paramref name="rangeEnd" />.
    ///     Starting and ending day are taken into account.
    /// </summary>
    /// <param name="date">Date to be checked</param>
    /// <param name="rangeStart">Start date of range</param>
    /// <param name="rangeEnd">End date of range</param>
    public static bool Between(this DateTime date, DateTime rangeStart, DateTime rangeEnd)
    {
        return date.Date >= rangeStart.Date && date.Date <= rangeEnd.Date;
    }

    /// <summary>
    ///     Checks, whether date falls in the specified range.
    ///     Starting and ending day are taken into account.
    /// </summary>
    /// <param name="date">Date to be checked</param>
    /// <param name="range">Range of dates</param>
    public static bool Between(this DateTime date, DateRange range)
    {
        return date.Between(range.StartDate, range.EndDate);
    }

    /// <summary>
    ///     Checks, whether date falls in any range in <paramref name="ranges" /> collection.
    ///     Starting and ending day are taken into account.
    /// </summary>
    /// <param name="date">Date to be checked</param>
    /// <param name="ranges">Collection of date ranges</param>
    public static bool Between(this DateTime date, IEnumerable<DateRange> ranges)
    {
        return ranges.Any(d => date.Between(d));
    }

    /// <summary>
    ///     Extracts week day number from date.
    ///     Monday is the first day of the week, and Sunday is last.
    /// </summary>
    /// <param name="date"></param>
    /// <returns>One-based number of the day in the week</returns>
    public static int ExtractWeekday(this DateTime date)
    {
        var weekDay = date.DayOfWeek;

        if (weekDay == DayOfWeek.Sunday)
            return 7;
        return (int)weekDay;
    }

    /// <summary>
    ///     Returns the date of the first day of chosen month
    /// </summary>
    /// <param name="date"></param>
    /// <returns></returns>
    public static DateTime FirstDayOfMonth(this DateTime date)
    {
        return (new DateTime(date.Year, date.Month, 1)).Date;
    }

    /// <summary>
    ///     Returns the date of the last day of chosen month
    /// </summary>
    /// <param name="date"></param>
    /// <returns></returns>
    public static DateTime LastDayOfMonth(this DateTime date)
    {
        return (new DateTime(date.Year, date.Month, 1)).AddMonths(1).AddDays(-1);
    }

    /// <summary>
    ///     Returns the date of the first day of current month
    /// </summary>
    /// <returns></returns>
    public static DateTime FirstDayOfCurrentMonth()
    {
        return DateTime.Today.FirstDayOfMonth();
    }

    /// <summary>
    ///     Returns the date of the first day of current year
    /// </summary>
    /// <returns></returns>
    public static DateTime FirstDayOfCurrentYear()
    {
        return new DateTime(DateTime.Today.Year, 1, 1);
    }

    /// <summary>
    ///     Returns the date of the last day of chosen month
    /// </summary>
    /// <returns></returns>
    public static DateTime LastDayOfCurrentMonth()
    {
        return DateTime.Today.LastDayOfMonth();
    }

    /// <summary>
    ///     Returns the date of the first day of current month
    /// </summary>
    /// <returns></returns>
    public static DateTime GetDayOfCurrentMonth(int day)
    {
        return new DateTime(DateTime.Today.Year, DateTime.Today.Month, day);
    }

    /// <summary>
    ///     Calculates first date of quarter.
    /// </summary>
    /// <param name="date">Date</param>
    /// <returns>First date of quarter</returns>
    public static DateTime FirstDayOfQuarter(this DateTime date)
    {
        var month = date.Month;

        return new DateTime(date.Year, 3 * ((month - 1) / 3) + 1, 1);
    }

    /// <summary>
    ///     Calculates first date of quarter.
    /// </summary>
    /// <param name="date">Date</param>
    /// <returns>First date of quarter</returns>
    public static DateTime LastDayOfQuarter(this DateTime date)
    {
        return date.FirstDayOfQuarter().AddMonths(2).LastDayOfMonth();
    }

    /// <summary>
    ///     Returns the date of the last day of chosen year
    /// </summary>
    /// <param name="date"></param>
    /// <returns></returns>
    public static DateTime FirstDayOfYear(this DateTime date)
    {
        return (new DateTime(date.Year, 1, 1)).Date;
    }

    /// <summary>
    ///     Returns the date of the last day of chosen year
    /// </summary>
    /// <param name="date"></param>
    /// <returns></returns>
    public static DateTime LastDayOfYear(this DateTime date)
    {
        return (new DateTime(date.Year, 1, 1)).AddYears(1).AddDays(-1);
    }

    /// <summary>
    ///     Returns the date of the last day of current year
    /// </summary>
    /// <returns></returns>
    public static DateTime LastDayOfCurrentYear()
    {
        return DateTime.Today.LastDayOfYear();
    }

    /// <summary>
    ///     Returns the date of the first day of current quarter
    /// </summary>
    /// <returns></returns>
    public static DateTime FirstDayOfCurrentQuarter()
    {
        return DateTime.Today.FirstDayOfQuarter();
    }

    /// <summary>
    ///     Returns the date of the last day of current quarter
    /// </summary>
    /// <returns></returns>
    public static DateTime LastDayOfCurrentQuarter()
    {
        return DateTime.Today.LastDayOfQuarter();
    }

    /// <summary>
    ///     Converts collection of dates to sorted collection of date ranges.
    ///     Every date in the source collection will be treated as date, time is rejected.
    /// </summary>
    /// <param name="collection"></param>
    /// <param name="maxValue">Maximum value from collection taken for the generation of ranges</param>
    /// <returns>Sorted collection of date ranges</returns>
    public static IOrderedEnumerable<DateRange> ToDateRanges(this IList<DateTime> collection,
        DateTime? maxValue = null)
    {
        var ranges = new List<DateRange>();

        if (collection == null)
            return null;

        if (!collection.Any())
            return ranges.OrderBy(i => i.StartDate);

        var dateOnlyHashSet = new HashSet<DateTime>(collection.Select(i => i.Date));
        var startDate = dateOnlyHashSet.Min();
        var endDate = maxValue.HasValue ? maxValue.Value.Date : dateOnlyHashSet.Max();

        DateRange range = null;
        for (; startDate <= endDate; startDate = startDate.AddDays(1).Date)
        {
            var isIncollection = dateOnlyHashSet.Contains(startDate);
            var rangeStarted = range != null;

            if (rangeStarted && !isIncollection)
            {
                range.EndDate = startDate.AddDays(-1).Date;

                ranges.Add(range);

                range = null;
            }
            else if (!rangeStarted && isIncollection)
            {
                range = new DateRange(startDate.Date, startDate.Date);
            }
        }

        if (range != null)
        {
            range.EndDate = startDate.AddDays(-1).Date;

            ranges.Add(range);
        }

        return ranges.OrderBy(i => i.StartDate);
    }

    public static DateTime GetFirstDayOfWeek(this DateTime givenDate)
    {
        var tmp = givenDate.Date;
        while (tmp.AddDays(-1).Month == givenDate.Month && tmp.DayOfWeek > DayOfWeek.Monday) tmp = tmp.AddDays(-1);
        return tmp;
    }

    public static DateTime GetLastDayOfWeek(this DateTime givenDate)
    {
        var tmp = givenDate.Date;
        while (tmp.AddDays(1).Month == givenDate.Month && tmp.DayOfWeek != DayOfWeek.Sunday) tmp = tmp.AddDays(1);
        return tmp;
    }

    public static DateTime? GoToFirstDayOfWeek(this DateTime date, int weeks, int dayOfWeek)
    {
        var tmp = date.Date;
        var firstDayOfMonth = new DateTime(date.Year, date.Month, 1);
        var firstDay = CultureInfo.CurrentCulture.DateTimeFormat.FirstDayOfWeek;

        for (var i = 0; i < weeks - 1; i++)
        {
            if (i > 0) tmp = tmp.AddDays(1);

            while (tmp.AddDays(1).Month == date.Month && (tmp.DayOfWeek != firstDay || tmp == firstDayOfMonth))
                tmp = tmp.AddDays(1);
        }

        while (tmp.AddDays(1).Month == date.Month && tmp.DayOfWeek != (DayOfWeek)dayOfWeek) tmp = tmp.AddDays(1);

        if (tmp.DayOfWeek != (DayOfWeek)dayOfWeek) return null;

        return tmp;
    }

    public static DateTime GoToFirstDayOfLastWeek(this DateTime date, int dayOfWeek)
    {
        var tmp = date.Date.AddMonths(1).AddDays(-1);
        while (tmp.AddDays(-1).Month == date.Month && tmp.DayOfWeek != (DayOfWeek)dayOfWeek) tmp = tmp.AddDays(-1);
        return tmp;
    }

    /// <summary>
    ///     Function that returns all dates in selected year
    /// </summary>
    /// <param name="year">selected year</param>
    /// <returns>all dates in selected year</returns>
    public static List<DateTime> GetDates(int year)
    {
        return Enumerable.Range(1, 12) // Months: 1, 2 ... 12 etc.
            .SelectMany(month => GetDates(year, month))
            .ToList();
    }

    /// <summary>
    ///     Function that returns all dates in selected month of a year
    /// </summary>
    /// <param name="year">selected year</param>
    /// <param name="month">selected month</param>
    /// <returns>all dates in selected month of a year</returns>
    public static List<DateTime> GetDates(int year, int month)
    {
        return Enumerable.Range(1, DateTime.DaysInMonth(year, month)) // Days: 1, 2 ... 31 etc.
            .Select(day => new DateTime(year, month, day)) // Map each day to a date
            .ToList(); // Load dates into a list
    }

    public static DateTime Convert(string dateString, string format)
    {
        DateTime result;
        if (DateTime.TryParseExact(dateString, format, CultureInfo.InvariantCulture,
                DateTimeStyles.None, out result))
            return result;

        return DateTime.TryParse(dateString, CultureInfo.InvariantCulture,
            DateTimeStyles.None, out result)
            ? result
            : DateTime.Parse(dateString);
    }

    /// <summary>
    ///     Compares two nullable date time object
    /// </summary>
    /// <param name="d1"></param>
    /// <param name="d2"></param>
    /// <returns>Greater date or null if both objects are null</returns>
    public static DateTime? GetGraterDateOrNull(DateTime? d1, DateTime? d2)
    {
        if (!d1.HasValue && !d2.HasValue)
            return null;
        if (d1.HasValue && d2.HasValue)
            return (d1.Value > d2.Value) ? d1.Value : d2.Value;

        return d1.HasValue ? d1.Value : d2.Value;
    }

    public static double ToUnixTime(this DateTime dateTime)
    {
        return (dateTime - new DateTime(1970, 1, 1).ToLocalTime()).TotalSeconds;
    }

    public static string ToUserFriendlyTimePeriod(this TimeSpan timespan)
    {
        string returnString = null;

        if (timespan.TotalHours < 1)
            returnString = string.Format("{0} minutes ago", timespan.Minutes);
        else if (timespan.TotalHours < 24)
            returnString = string.Format("{0} hours ago", timespan.Hours);
        else if (timespan.TotalDays < 2)
            returnString = string.Format("1 day and {0} hours ago", timespan.Hours);
        else if (timespan.TotalDays > 2) returnString = string.Format("{0} days ago", timespan.Days);

        return returnString;
    }
}