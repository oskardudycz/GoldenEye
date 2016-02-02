using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace GoldenEye.Backend.Core.Entity
{
    public class AuditableEntity : EntityBase, IAuditableEntity
    {
        public DateTime Created { get; set; }
        public int CreatedBy { get; set; }
        public DateTime LastModified { get; set; }
        public int LastModifiedBy { get; set; }
    }
}