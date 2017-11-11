using System;
using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Business.Entities
{
    public class TaskEntity : AuditableEntity
    {
        public string Name { get; set; }

        public DateTime Date { get; set; }

        public int Progress { get; set; }
    }
}
