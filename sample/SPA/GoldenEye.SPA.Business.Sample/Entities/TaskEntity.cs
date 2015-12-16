using System;
using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.SPA.Business.Sample.Entities
{
    public class TaskEntity : EntityBase
    {
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

        public string ModificationBy { get; set; }
    }
}
