using System.Runtime.Serialization;
using GoldenEye.Shared.Core.Objects.Responses;

namespace GoldenEye.Shared.Core.Validation.Responses
{
    public interface IValidatableResponse: IResponse
    {
        [DataMember]
        FluentValidation.Results.ValidationResult ValidationResult { get; set; }
    }
}
