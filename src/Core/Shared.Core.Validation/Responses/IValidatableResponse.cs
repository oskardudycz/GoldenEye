using GoldenEye.Shared.Core.Objects.Responses;
using System.Runtime.Serialization;

namespace GoldenEye.Shared.Core.Validation.Responses
{
    public interface IValidatableResponse : IResponse
    {
        [DataMember]
        FluentValidation.Results.ValidationResult ValidationResult { get; set; }
    }
}
