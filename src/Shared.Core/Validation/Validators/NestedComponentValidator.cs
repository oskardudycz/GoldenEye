using FluentValidation;

namespace GoldenEye.Shared.Core.Validation.Validators
{
    public class NestedComponentValidator<T> : AbstractValidator<T>
    {
        public override FluentValidation.Results.ValidationResult Validate(T instance)
        {
            return base.Validate(instance);
        }
    }
}
