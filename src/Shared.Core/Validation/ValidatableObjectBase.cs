using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using FluentValidation.Results;
using ValidationResult = System.ComponentModel.DataAnnotations.ValidationResult;

namespace GoldenEye.Shared.Core.Validation
{
    [Serializable]
    public class ValidatableObjectBase : IValidatable
    {
        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            return Validate().Errors
              .Select(e => new ValidationResult(e.ErrorMessage, new[] { e.PropertyName })).ToList();
        }

        public FluentValidation.Results.ValidationResult Validate()
        {
            var validationResult = ValidationEngine.Validate(GetType(), this);

            if (validationResult == null || validationResult.Errors == null)
            {
                return new FluentValidation.Results.ValidationResult();
            }

            return validationResult;
        }

        public FluentValidation.Results.ValidationResult Validate(object additonalContext)
        {
            var validationResult = ValidationEngine.Validate(GetType(), this, additonalContext);

            if (validationResult == null || validationResult.Errors == null)
            {
                return new FluentValidation.Results.ValidationResult();
            }

            return validationResult;
        }
    }

    public static class ValidatableObjectBaseExtension
    {
        public static bool IsValid(this FluentValidation.Results.ValidationResult validationResult)
        {
            return validationResult == null || validationResult.IsValid;
        }

        public static bool IsValid(this IList<ValidationFailure> validationResults)
        {
            return validationResults == null || validationResults.Count == 0;
        }

        public static IList<ValidationResult> ToStandardValidationResult(this IList<ValidationFailure> validationResults)
        {
            if (validationResults == null)
                return null;

            return validationResults.Select(e => new ValidationResult(e.ErrorMessage, new[] { e.PropertyName })).ToList();
        }

        public static IList<string> ToStringErrorMessages(this IList<ValidationFailure> validationResults)
        {
            if (validationResults == null)
                return null;

            return validationResults.Select(x => x.ErrorMessage).ToList();
        }

        public static string SimpleValidationErrorOrNull(this IList<ValidationFailure> validationResults, Func<object, string> customStateToString = null)
        {
            if (validationResults.IsValid())
            {
                return null;
            }

            var firstError = validationResults.First();

            if (firstError.CustomState == null || customStateToString == null)
            {
                return firstError.ErrorMessage;
            }

            return customStateToString(firstError.CustomState);
        }
    }

    public enum ValidationErrorType
    {
        ElementSpecific = 0,
        Summary
    }
}