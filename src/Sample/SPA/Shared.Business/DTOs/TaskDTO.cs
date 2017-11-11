using System;
using FluentValidation.Attributes;
using GoldenEye.Shared.Business.Validators;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Shared.Business.DTOs
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