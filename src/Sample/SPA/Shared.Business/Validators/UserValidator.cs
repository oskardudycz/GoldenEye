using FluentValidation;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Shared.Business.Validators
{
    public class UserValidator: AbstractValidator<UserDTO>
    {
        public UserValidator()
        {
            RuleFor(user => user.FirstName).NotEmpty();
            RuleFor(user => user.LastName).NotEmpty();
            RuleFor(user => user.Email)
                .NotEmpty()
                .EmailAddress();
        }
    }
}