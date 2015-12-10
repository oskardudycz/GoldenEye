using System;
using FluentValidation.Attributes;
using GoldenEye.Shared.Business.Validators;
using GoldenEye.Shared.Core.DTOs;

namespace GoldenEye.Shared.Business.DTOs
{
    [Validator(typeof(TaskValidator))]
    public class TaskDTO: DTOBase
    {
        public int Id { get; set; }

        public int? CustomerId { get; set; }

        public int? TypeId { get; set; }

        public string Name { get; set; }

        public int? CustomerColor { get; set; }

        public DateTime Date { get; set; }

        public string Number { get; set; }

        public bool? IsInternal { get; set; }

        public int? Amount { get; set; }

        public int? PlannedTime { get; set; }

        public DateTime? PlannedStartDate { get; set; }

        public DateTime? PlannedEndDate { get; set; }

        public int? Color { get; set; }

        public DateTime? PlanningDate { get; set; }

        public string Description { get; set; }

        public DateTime? ModificationDate { get; set; }

        public int Progress { get; set; }
    }
}