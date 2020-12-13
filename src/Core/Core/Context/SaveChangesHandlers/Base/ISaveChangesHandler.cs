using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Core.Repositories.SaveChangesHandlers.Base
{
    public interface ISaveChangesHandler
    {
        void Handle(IProvidesAuditInfo context);
    }
}
