using System;
using GoldenEye.Backend.Core.Entity;

namespace $rootnamespace$.Entities
{
    public class TaskEntity : AuditableEntity
    {
        public string Name { get; set; }

        public DateTime Date { get; set; }

        public int Progress { get; set; }
    }
}
