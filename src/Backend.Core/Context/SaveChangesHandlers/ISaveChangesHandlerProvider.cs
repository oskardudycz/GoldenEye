using System.Data.Entity;
using GoldenEye.Backend.Core.Context.SaveChangesHandler.Base;

namespace GoldenEye.Backend.Core.Context.SaveChangesHandlers
{
    public interface ISaveChangesHandlerProvider
    {
        void Clear();
        void Add(ISaveChangesHandler handler);
        void RunAll(DbContext context);
    }
}