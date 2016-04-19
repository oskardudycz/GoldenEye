namespace GoldenEye.Backend.Core.Context.SaveChangesHandlers.Base
{
    public interface ISaveChangesHandler
    {
        void Handle(IDataContext context);
    }
}
