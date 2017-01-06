using System;
using FluentValidation.Attributes;
using GoldenEye.Shared.Core.Objects.DTO;
using Shared.Business.Validators;

namespace Shared.Business.DTOs
{
    [Validator(typeof(TaskValidator))]
    public class TaskDTO: DTOBase
    {
        public int Id { get; set; }
        
        public string Name { get; set; }

        public DateTime Date { get; set; }

        public int Progress { get; set; }
    }
}