using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;
using FluentValidation;
using FluentValidation.Results;

namespace Shared.Core
{
    public abstract class Validatable
    {
        private ValidationResult validationResult = null;
        [NotMapped]
        [Browsable(false)]
        public ValidationResult ValidationResult
        {
            get { return validationResult; }
            set { validationResult = value; }
        }
        [NotMapped]
        [Browsable(false)]
        public bool Valid
        {
            get { return (validationResult == null || validationResult.Errors == null || validationResult.Errors.Count == 0); }
        }
        private void Validate(IValidator validator)
        {
            validationResult = validator.Validate(this);
        }
        public virtual bool Validate()
        {
            var objectType = this.GetType();

            if (objectType.BaseType != null && objectType.Namespace == "System.Data.Entity.DynamicProxies")
            {
                objectType = objectType.BaseType;
            }
            var type = objectType.CustomAttributes;

            var validatorAttribute = type.First(x => x.AttributeType.Name == "ValidatorAttribute");
            var validatorType = validatorAttribute.ConstructorArguments.First(x => x.ArgumentType.Name == "Type").Value;
            var validator = Activator.CreateInstance((Type)validatorType);


            Validate((IValidator)validator);

            return Valid;
        }


    }
}