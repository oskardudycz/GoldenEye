using System;
using System.Collections.Generic;
using System.Linq;
using GoldenEye.Extensions.Collections;
using GoldenEye.Objects.Dates;

namespace GoldenEye.Extensions.Basic;

public static class DateRangeExtensions
{
    /// <summary>
    ///     Consolidates ranges in collection by merging ones with difference less than or equal to 1 day between corresponding
    ///     end and start dates.
    ///     May modify elements in the collection.
    /// </summary>
    public static IEnumerable<DateRange> Consolidate(this IEnumerable<DateRange> ranges)
    {
        if (ranges == null || !ranges.Any())
            return ranges;

        var consolidatedRanges = new List<DateRange>();

        ranges = ranges.OrderBy(i => i.StartDate).ToList();

        var range = ranges.First();
        DateRange current;

        for (var index = 1; index < ranges.Count(); ++index)
        {
            current = ranges.ElementAt(index);

            if ((current.StartDate - range.EndDate).TotalDays <= 1)
            {
                range.EndDate = current.EndDate;
            }
            else
            {
                consolidatedRanges.Add(range);

                range = current;
            }
        }

        consolidatedRanges.Add(range);

        return consolidatedRanges;
    }

    /// <summary>
    ///     Method returns new collection of ranges, which occur after <paramref name="startDate" />.
    ///     Every range containing the date is adjusted to occur after this date.
    ///     May modify elements in the collection
    /// </summary>
    /// <param name="startDate">Date, to which every range in collection is adjusted</param>
    /// <returns></returns>
    public static IEnumerable<DateRange> AdjustToDate(this IEnumerable<DateRange> ranges, DateTime startDate)
    {
        if (ranges == null || !ranges.Any())
            return ranges;

        startDate = startDate.Date;

        // first, sort the ranges, so manipulation is easier
        var newRanges = ranges.OrderBy(i => i.StartDate).ToList();

        // remove all ranges, which occur before startDate
        // equality is not checked, because same-day range for startDate is allowed
        newRanges.RemoveAll(i => i.EndDate.Date < startDate);

        if (newRanges.Any())
            newRanges.Where(i => i.Contains(startDate)).ForEach(i =>
                i.StartDate = startDate
            );

        return newRanges;
    }
}