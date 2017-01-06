using FluentValidation;
using Shared.Business.DTOs;

namespace Shared.Business.Validators
{
    public class TaskValidator : AbstractValidator<TaskDTO>
    {
        public TaskValidator()
        {
            RuleFor(task => task.Name).NotEmpty();
            RuleFor(task => task.Date).NotEmpty();
            RuleFor(task => task.Progress).InclusiveBetween(1, 100);
        }
    }
}