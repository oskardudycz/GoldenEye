using System.Collections.Generic;

namespace GoldenEye.Backend.Core.Entity
{
    public interface IProvidesAuditInfo
    {
        IEnumerable<IEntityEntry> Changes { get; }
    }
}
