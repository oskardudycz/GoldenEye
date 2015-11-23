using System;
using Backend.Core.Entity;
using Shared.Business.Validators;
using FluentValidation.Attributes;

namespace Backend.Business.Entities
{
    [Validator(typeof(TaskValidator))]
    public class TaskEntity : EntityBase
    {
        public string TaskName { get; set; }
        public int Number { get; set; }
        public DateTime? Date { get; set; }
        public string Type { get; set; }
        public bool IsInternal { get; set; }
        public int Amount { get; set; }
        public TimeSpan Time { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime? PlanDate { get; set; }
        public string Description { get; set; }
        public string Color { get; set; }
        public float Progress { get; set; }
        public int Status { get; set; }
        public int CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }
        public int ModifiedBy { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public bool IsDeleted { get; set; }
    }
}