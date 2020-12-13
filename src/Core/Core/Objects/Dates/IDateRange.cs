using System;

namespace GoldenEye.Core.Objects.Dates
{
    public interface IDateRange
    {
        DateTime? StartDate { get; }

        DateTime? EndDate { get; }
    }
}
