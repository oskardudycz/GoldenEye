using System.Collections.Generic;
using GoldenEye.Context.SaveChangesHandlers.Base;
using GoldenEye.Entities;

namespace GoldenEye.Context.SaveChangesHandlers;

public class SaveChangesProcessor: ISaveChangesProcessor
{
    public static ISaveChangesProcessor Instance = new SaveChangesProcessor();

    private readonly IList<ISaveChangesHandler> _handlers =
        new List<ISaveChangesHandler> {new AuditInfoSaveChangesHandler()};

    public void Clear()
    {
        _handlers.Clear();
    }

    public void Add(ISaveChangesHandler handler)
    {
        _handlers.Add(handler);
    }

    public void RunAll(IProvidesAuditInfo context)
    {
        foreach (var handler in _handlers) handler.Handle(context);
    }
}