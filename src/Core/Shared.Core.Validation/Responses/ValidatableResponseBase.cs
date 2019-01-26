using System;
using System.Runtime.Serialization;

namespace GoldenEye.Shared.Core.Validation.Responses
{
    [Obsolete]
    public class ValidatableResponseBase : ValidatableObjectBase, IValidatableResponse
    {
        [DataMember]
        public FluentValidation.Results.ValidationResult ValidationResult { get; set; }

        public ValidatableResponseBase()
        {
            ValidationResult = new FluentValidation.Results.ValidationResult();
        }
    }
}