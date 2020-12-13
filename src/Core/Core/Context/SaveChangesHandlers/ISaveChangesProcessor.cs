using GoldenEye.Core.Entity;
using GoldenEye.Core.Repositories.SaveChangesHandlers.Base;

namespace GoldenEye.Core.Repositories.SaveChangesHandlers
{
    public interface ISaveChangesProcessor
    {
        void Clear();

        void Add(ISaveChangesHandler handler);

        void RunAll(IProvidesAuditInfo context);
    }
}
