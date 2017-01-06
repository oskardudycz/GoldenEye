using System;
using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Business.Entities
{
    public class TaskEntity : AuditableEntity
    {

        public string Name { get; set; }

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

        public int Progress { get; set; }
    }
}
