using Backend.Core.Repository;
using Backend.Business.Entities;

namespace Backend.Business.Repository
{
    public interface IModelerUserRepository : IReadonlyRepository<ModelerUserEntity>
    {
        bool Authorize(string username, string password);
        ModelerUserEntity Find(string username, string password);
    }
}
