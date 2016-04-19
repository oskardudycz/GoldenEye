using System;

namespace GoldenEye.Backend.Core.Entity
{
    interface IAuditableEntity: IEntity
    {
        DateTime Created { get; set; }
        int? CreatedBy { get; set; }
        DateTime? LastModified { get; set; }
        int? LastModifiedBy { get; set; }
    }
}
