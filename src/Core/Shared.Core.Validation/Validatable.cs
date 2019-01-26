using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Reflection;
using FluentValidation;
using FluentValidation.Results;

namespace GoldenEye.Shared.Core.Validation
{
    [Obsolete]
    public abstract class Validatable
    {
        [NotMapped]
        [Browsable(false)]
        public ValidationResult ValidationResult { get; set; } = null;

        [NotMapped]
        [Browsable(false)]
        public bool Valid
        {
            get { return (ValidationResult == null || ValidationResult.Errors == null || ValidationResult.Errors.Count == 0); }
        }

        private void Validate(IValidator validator)
        {
            ValidationResult = validator.Validate(this);
        }

        public virtual bool Validate()
        {
            var objectType = GetType();

            if (objectType.GetTypeInfo().BaseType != null && objectType.Namespace == "System.Data.Entity.DynamicProxies")
            {
                objectType = objectType.GetTypeInfo().BaseType;
            }
            var type = objectType.GetTypeInfo().CustomAttributes;

            var validatorAttribute = type.First(x => x.AttributeType.Name == "ValidatorAttribute");
            var validatorType = validatorAttribute.ConstructorArguments.First(x => x.ArgumentType.Name == "Type").Value;
            var validator = Activator.CreateInstance((Type)validatorType);

            Validate((IValidator)validator);

            return Valid;
        }
    }
}