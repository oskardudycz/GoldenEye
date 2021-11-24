using System;

namespace GoldenEye.Objects.Dates;

public interface IDateRange
{
    DateTime? StartDate { get; }

    DateTime? EndDate { get; }
}