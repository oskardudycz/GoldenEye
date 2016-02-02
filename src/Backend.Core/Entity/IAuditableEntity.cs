using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.Entity
{
    interface IAuditableEntity: IEntity
    {
        DateTime Created { get; set; }
        int CreatedBy { get; set; }
        DateTime LastModified { get; set; }
        int LastModifiedBy { get; set; }
    }
}
