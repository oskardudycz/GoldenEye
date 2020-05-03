using System.ComponentModel.DataAnnotations;
using ValidationResult = FluentValidation.Results.ValidationResult;

namespace GoldenEye.Shared.Core.Validation
{
    public interface IValidatable: IValidatableObject
    {
        ValidationResult Validate();
    }
}
