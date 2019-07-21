using GoldenEye.Backend.Core.Context.SaveChangesHandlers.Base;

namespace GoldenEye.Backend.Core.Context.SaveChangesHandlers
{
    public interface ISaveChangesProcessor
    {
        void Clear();

        void Add(ISaveChangesHandler handler);

        void RunAll(IDataContext context);
    }
}
