using System;
using System.ComponentModel.DataAnnotations;
using System.Reflection;
using FluentValidation;
using FluentValidation.Attributes;
using ValidationResult = FluentValidation.Results.ValidationResult;

namespace GoldenEye.Shared.Core.Validation
{
    [Obsolete]
    public static class ValidationEngine
    {
        public static IValidator GetValidator<T>()
        {
            return GetValidator(typeof(T));
        }

        public static IValidator GetValidator(Type type, object additionalValue = null)
        {
            var attribute = type.GetTypeInfo().GetCustomAttribute<ValidatorAttribute>();

            if (attribute == null)
                return null;

            var validatorType = attribute.ValidatorType;

            if (validatorType.GetTypeInfo().IsGenericType)
            {
                validatorType = validatorType.MakeGenericType(type);
            }

            if (additionalValue == null)
            {
                return (IValidator)Activator.CreateInstance(validatorType);
            }
            else
            {
                return (IValidator)Activator.CreateInstance(validatorType, additionalValue);
            }
        }

        public static ValidationResult Validate<T>(T obj) where T : IValidatableObject
        {
            return Validate(typeof(T), obj);
        }

        internal static ValidationResult Validate(Type type, IValidatableObject obj)
        {
            var validator = GetValidator(type);

            return validator != null ? validator.Validate(obj) : new ValidationResult();
        }

        internal static ValidationResult Validate(Type type, IValidatableObject obj, object additionalValue)
        {
            var validator = GetValidator(type, additionalValue);

            return validator != null ? validator.Validate(obj) : new ValidationResult();
        }
    }
}