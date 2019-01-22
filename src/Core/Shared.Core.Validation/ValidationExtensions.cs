using System;
using System.Collections.Generic;
using FluentValidation;
using GoldenEye.Shared.Core.Validation.Validators;

namespace GoldenEye.Shared.Core.Validation
{
    public static class ValidationExtensions
    {
        public static CollectionValidatorExtensions.ICollectionValidatorRuleBuilder<T, TCollectionElement>
            SetCollectionValidator<T, TCollectionElement>(
            this IRuleBuilder<T, IEnumerable<TCollectionElement>> ruleBuilder)
        {
#pragma warning disable CS0618 // Type or member is obsolete
            return ruleBuilder.SetCollectionValidator(new NestedComponentValidator<TCollectionElement>());
#pragma warning restore CS0618 // Type or member is obsolete
        }

        public static IRuleBuilderOptions<T, TProperty> UseNestedValidator<T, TProperty>(
            this IRuleBuilder<T, TProperty> ruleBuilder)
        {
#pragma warning disable 612, 618
            return ruleBuilder.SetValidator((IValidator<TProperty>)ValidationEngine.GetValidator<TProperty>());
#pragma warning restore 612, 618
        }

        public static IRuleBuilderOptions<T, TProperty> MustNot<T, TProperty>(this IRuleBuilder<T, TProperty> ruleBuilder, Func<TProperty, bool> predicate)
        {
            return ruleBuilder.SetValidator(new MustNotValidator<TProperty>(predicate));
        }
    }
}