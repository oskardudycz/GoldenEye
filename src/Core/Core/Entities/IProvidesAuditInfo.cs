using System.Collections.Generic;
using GoldenEye.Core.Entities;

namespace GoldenEye.Core.Entity
{
    public interface IProvidesAuditInfo
    {
        IEnumerable<IEntityEntry> Changes { get; }
    }
}
