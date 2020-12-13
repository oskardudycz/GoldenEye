using System;

namespace GoldenEye.Shared.Core.Objects.Dates
{
    public interface IDateRange
    {
        DateTime? StartDate { get; }

        DateTime? EndDate { get; }
    }
}
