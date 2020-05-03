using System;
using System.Runtime.Serialization;
using FluentValidation.Results;

namespace GoldenEye.Shared.Core.Validation.Responses
{
    [Obsolete]
    public class ValidatableResponseBase: ValidatableObjectBase, IValidatableResponse
    {
        public ValidatableResponseBase()
        {
            ValidationResult = new ValidationResult();
        }

        [DataMember] public ValidationResult ValidationResult { get; set; }
    }
}
