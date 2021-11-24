using System;
using GoldenEye.Objects.Audit;

namespace GoldenEye.Entities;

internal interface IAuditableEntity<TKey>: IEntity<TKey>, IAuditable
{
}

internal interface IAuditableEntity: IAuditableEntity<Guid>
{
}