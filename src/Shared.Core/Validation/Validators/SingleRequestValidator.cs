using System.Collections.Generic;
using System.Linq;
using FluentValidation;
using FluentValidation.Results;
using GoldenEye.Shared.Core.Objects.Requests;

namespace GoldenEye.Shared.Core.Validation.Validators
{
    /// <summary>
    /// Single request validator
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class SingleRequestValidator<T> : AbstractValidator<T> where T : ISingleRequest
    {
        public SingleRequestValidator()
        {
            RuleFor(el => el.Item).NotNull();
        }

        ///// <summary>
        ///// Checks if requests item is not null and if it has value validates by nested validator.
        ///// </summary>
        ///// <param name="instance"></param>
        ///// <returns></returns>
        //public override ValidationResult Validate(T instance)
        //{
        //    var result = base.Validate(instance);

        //    var innerType = typeof(T).GetGenericArguments().First();
        //    var validator = ValidationEngine.GetValidator(innerType);

        //    if (validator == null)
        //        return result;

        //    var itemValidation = validator.Validate(instance.Item);

        //    if (itemValidation.IsValid)
        //        return result;

        //    return new ValidationResult((result.Errors ?? new List<ValidationFailure>()).Concat(itemValidation.Errors));
        //}
    }
}