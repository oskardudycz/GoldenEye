using System;

namespace GoldenEye.Entities;

public abstract class AuditableEntity<TKey>: Entity<TKey>, IAuditableEntity<TKey>
{
    public DateTime Created { get; set; }
    public int? CreatedBy { get; set; }
    public DateTime? LastModified { get; set; }
    public int? LastModifiedBy { get; set; }
}

public class AuditableEntity: AuditableEntity<Guid>
{
}