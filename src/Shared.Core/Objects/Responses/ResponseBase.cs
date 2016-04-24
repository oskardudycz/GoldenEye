using System.Runtime.Serialization;
using GoldenEye.Shared.Core.Validation;

namespace GoldenEye.Shared.Core.Objects.Responses
{
    [DataContract]
    public abstract class ResponseBase : ValidatableObjectBase, IResponse
    {
        [DataMember]
        public FluentValidation.Results.ValidationResult ValidationResult { get; set; }

        public ResponseBase()
        {
            ValidationResult = new FluentValidation.Results.ValidationResult();
        }
    }
}