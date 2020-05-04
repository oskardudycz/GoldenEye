using System.Runtime.Serialization;
using FluentValidation.Results;
using GoldenEye.Shared.Core.Objects.Responses;

namespace GoldenEye.Shared.Core.Validation.Responses
{
    public interface IValidatableResponse: IResponse
    {
        [DataMember] ValidationResult ValidationResult { get; set; }
    }
}
