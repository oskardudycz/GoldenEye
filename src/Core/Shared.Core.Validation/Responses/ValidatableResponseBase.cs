using System.Runtime.Serialization;

namespace GoldenEye.Shared.Core.Validation.Responses
{
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
