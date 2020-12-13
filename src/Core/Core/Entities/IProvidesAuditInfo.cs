using System.Collections.Generic;

namespace GoldenEye.Core.Entity
{
    public interface IProvidesAuditInfo
    {
        IEnumerable<IEntityEntry> Changes { get; }
    }
}
