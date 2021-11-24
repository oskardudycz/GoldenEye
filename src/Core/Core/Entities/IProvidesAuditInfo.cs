using System.Collections.Generic;

namespace GoldenEye.Entities;

public interface IProvidesAuditInfo
{
    IEnumerable<IEntityEntry> Changes { get; }
}