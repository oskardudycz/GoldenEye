using GoldenEye.Context.SaveChangesHandlers.Base;
using GoldenEye.Entities;

namespace GoldenEye.Context.SaveChangesHandlers;

public interface ISaveChangesProcessor
{
    void Clear();

    void Add(ISaveChangesHandler handler);

    void RunAll(IProvidesAuditInfo context);
}