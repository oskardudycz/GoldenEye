using System.Collections.Generic;
using System.Data.Entity;
using GoldenEye.Backend.Core.Context.SaveChangesHandler.Base;

namespace GoldenEye.Backend.Core.Context.SaveChangesHandlers
{
    public class SaveChangesHandlerProvider : ISaveChangesHandlerProvider
    {
        public static ISaveChangesHandlerProvider Instance = new SaveChangesHandlerProvider();

        private readonly IList<ISaveChangesHandler> _handlers = new List<ISaveChangesHandler>{new AuditInfoSaveChangesHandler()};
        
        public void Clear()
        {
            _handlers.Clear();
        }

        public void Add(ISaveChangesHandler handler)
        {
            _handlers.Add(handler);
        }

        public void RunAll(DbContext context)
        {
            foreach (var handler in _handlers)
            {
                handler.Handle(context);
            }
        }
    }
}
