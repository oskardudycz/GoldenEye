using System;
using FluentValidation.Validators;

namespace GoldenEye.Shared.Core.Validation.Validators
{
    public class MustNotValidator<TProperty> : PropertyValidator
    {
        private readonly Func<TProperty, bool> _action;

        public MustNotValidator(Func<TProperty, bool> action)
            : base("")
        {
            _action = action;
        }

        protected override bool IsValid(PropertyValidatorContext context)
        {
            if (context.PropertyValue is TProperty)
            {
                return !_action((TProperty)context.PropertyValue);
            }

            throw new ArgumentException();
        }
    }
}
