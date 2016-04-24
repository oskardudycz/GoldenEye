using System.Collections.Generic;
using System.Linq;
using FluentValidation;
using GoldenEye.Shared.Core.Objects.Dates;

namespace GoldenEye.Shared.Core.Validation.Validators
{
    public class DateRangeValidator : AbstractValidator<IEnumerable<IDateRange>>
    {
        public static bool ValidateDatesRanges(IEnumerable<IDateRange> instance)
        {
            if (instance == null) return true;
            var list = instance.OrderBy(o => o.StartDate).ToList();
            if (list.Count <= 1) return true;

            for (int i = 1; i < list.Count; i++)
            {
                if ((list[i - 1].StartDate <= list[i].EndDate) && (list[i - 1].EndDate >= list[i].StartDate))
                {
                    return false;
                }
            }
            return true;
        }
    }
}