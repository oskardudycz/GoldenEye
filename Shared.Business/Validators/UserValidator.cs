using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FluentValidation;
using Shared.Business.DTOs;

namespace Shared.Business.Validators
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