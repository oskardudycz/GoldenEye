using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Shared.Core;
using Backend.Core.Entity;

namespace Backend.Business.Entities
{
    public class TaskEntity: IHasId, IEntity
    {
        public int Id { get; set; }
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