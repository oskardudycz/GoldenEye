using System;
using FluentValidation.Validators;
using GoldenEye.Shared.Business.DTOs;

namespace GoldenEye.Shared.Business.Validators
{
    public class DateLaterThanNow: PropertyValidator
    {
        public DateLaterThanNow():base("Data musi być równa lub późniejsza od dzisiejszej") { }

        protected override bool IsValid(PropertyValidatorContext context)
        {
            var addTask = (TaskDTO)context.ParentContext.InstanceToValidate;
            var convertedDate = addTask.PlannedStartDate ?? DateTime.Now;
            return (convertedDate - DateTime.Now).TotalDays > 0;
        }
    }
}