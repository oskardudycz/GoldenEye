using System.Linq;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Repository;

namespace GoldenEye.Backend.Business.Repository
{
    public interface IModelerUserRepository : IReadonlyRepository<ModelerUserEntity>
    {
        bool Authorize(string username, string password);
        ModelerUserEntity Find(string username, string password);
        IQueryable<ModelerUserEntity> GetActive();
    }
}
