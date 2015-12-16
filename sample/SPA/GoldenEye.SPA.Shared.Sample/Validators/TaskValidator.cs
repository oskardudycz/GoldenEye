using FluentValidation;
using GoldenEye.SPA.Shared.Sample.DTOs;

namespace GoldenEye.SPA.Shared.Sample.Validators
{
    public class TaskValidator : AbstractValidator<TaskDTO>
    {
        public TaskValidator()
        {
            RuleFor(task => task.Name).NotEmpty();
            RuleFor(task => task.Number).NotEmpty();
            RuleFor(task => task.Amount).GreaterThan(0);
            RuleFor(task => task.Date).NotEmpty();
            RuleFor(task => task.Progress).InclusiveBetween(1, 100);
            RuleFor(task => task.PlannedEndDate).GreaterThan(task => task.PlannedStartDate.Value).When(task => task.PlannedStartDate.HasValue);
        }
    }
}