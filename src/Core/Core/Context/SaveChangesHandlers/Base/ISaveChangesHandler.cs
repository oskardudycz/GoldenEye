using GoldenEye.Core.Entity;

namespace GoldenEye.Core.Repositories.SaveChangesHandlers.Base
{
    public interface ISaveChangesHandler
    {
        void Handle(IProvidesAuditInfo context);
    }
}
