using GoldenEye.Entities;

namespace GoldenEye.Context.SaveChangesHandlers.Base;

public interface ISaveChangesHandler
{
    void Handle(IProvidesAuditInfo context);
}