using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Repositories.SaveChangesHandlers.Base;

namespace GoldenEye.Backend.Core.Repositories.SaveChangesHandlers
{
    public interface ISaveChangesProcessor
    {
        void Clear();

        void Add(ISaveChangesHandler handler);

        void RunAll(IProvidesAuditInfo context);
    }
}
