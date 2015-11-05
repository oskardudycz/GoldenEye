using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FluentValidation;
using Shared.Business.DTOs;

namespace Shared.Business.Validators
{
    public class TaskValidator : AbstractValidator<TaskDTO>
    {
        public TaskValidator()
        {
            RuleFor(task => task.TaskName).NotEmpty();
            RuleFor(task => task.Number).NotEmpty();
            RuleFor(task => task.Date).NotNull();
        }
    }
}