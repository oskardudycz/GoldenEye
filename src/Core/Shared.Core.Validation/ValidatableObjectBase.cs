using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using FluentValidation.Results;
using ValidationResult = FluentValidation.Results.ValidationResult;

namespace GoldenEye.Shared.Core.Validation
{
    [Serializable]
    [Obsolete]
    public class ValidatableObjectBase: IValidatable
    {
        public ValidationResult Validate()
        {
            var validationResult = ValidationEngine.Validate(GetType(), this);

            if (validationResult == null || validationResult.Errors == null) return new ValidationResult();

            return validationResult;
        }

        public IEnumerable<System.ComponentModel.DataAnnotations.ValidationResult> Validate(
            ValidationContext validationContext)
        {
            return Validate().Errors
                .Select(e =>
                    new System.ComponentModel.DataAnnotations.ValidationResult(e.ErrorMessage, new[] {e.PropertyName}))
                .ToList();
        }
    }

    [Obsolete]
    public static class ValidatableObjectBaseExtension
    {
        public static ValidationResult Validate(this IValidatable obj, object additonalContext)
        {
            var validationResult = ValidationEngine.Validate(obj.GetType(), obj, additonalContext);

            if (validationResult == null || validationResult.Errors == null) return new ValidationResult();

            return validationResult;
        }

        public static bool IsValid(this ValidationResult validationResult)
        {
            return validationResult == null || validationResult.IsValid;
        }

        public static bool IsValid(this IList<ValidationFailure> validationResults)
        {
            return validationResults == null || validationResults.Count == 0;
        }

        public static IList<System.ComponentModel.DataAnnotations.ValidationResult> ToStandardValidationResult(
            this IList<ValidationFailure> validationResults)
        {
            if (validationResults == null)
                return null;

            return validationResults.Select(e =>
                    new System.ComponentModel.DataAnnotations.ValidationResult(e.ErrorMessage, new[] {e.PropertyName}))
                .ToList();
        }

        public static IList<string> ToStringErrorMessages(this IList<ValidationFailure> validationResults)
        {
            if (validationResults == null)
                return null;

            return validationResults.Select(x => x.ErrorMessage).ToList();
        }

        public static string SimpleValidationErrorOrNull(this IList<ValidationFailure> validationResults,
            Func<object, string> customStateToString = null)
        {
            if (validationResults.IsValid()) return null;

            var firstError = validationResults.First();

            if (firstError.CustomState == null || customStateToString == null) return firstError.ErrorMessage;

            return customStateToString(firstError.CustomState);
        }
    }

    [Obsolete]
    public enum ValidationErrorType
    {
        ElementSpecific = 0,
        Summary
    }
}
