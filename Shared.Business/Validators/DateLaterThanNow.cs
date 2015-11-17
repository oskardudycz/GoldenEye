using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FluentValidation.Validators;
using Shared.Business.DTOs;

namespace Shared.Business.Validators
{
    public class DateLaterThanNow: PropertyValidator
    {
        public DateLaterThanNow():base("Data musi być późniejsza od dzisiejszej") { }

        protected override bool IsValid(PropertyValidatorContext context)
        {
            var addTask = context.ParentContext.InstanceToValidate as TaskDTO;
            var convertedDate = addTask.StartDate ?? DateTime.Now;
            return addTask != null && (convertedDate - System.DateTime.Now).TotalDays > 0;
        }
    }
}