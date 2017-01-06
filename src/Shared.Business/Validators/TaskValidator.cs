using FluentValidation;
using GoldenEye.Shared.Business.DTOs;

namespace GoldenEye.Shared.Business.Validators
{
    public class TaskValidator : AbstractValidator<TaskDTO>
    {
        public TaskValidator()
        {
            RuleFor(task => task.Name).NotEmpty();
            RuleFor(task => task.Date).NotEmpty();
            RuleFor(task => task.Progress).InclusiveBetween(0, 100);
        }
    }
}